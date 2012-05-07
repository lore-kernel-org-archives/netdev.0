From: "Hans Schillstrom" <hans@schillstrom.com>
Subject: Re[2]:  [v12 PATCH 2/3] NETFILTER module xt_hmark, new
	target for HASH based fwmark
Date: Mon, 7 May 2012 21:09:05 +0200 (CEST)
Message-ID: <0k0r53l.c3371735fb25ebebfdc229b1e397a36f@obelix.schillstrom.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="utf-8"
Content-Transfer-Encoding: 8BIT
Cc: "Hans Schillstrom" <hans.schillstrom@ericsson.com>,
	"kaber@trash.net" <kaber@trash.net>,
	"jengelh@medozas.de" <jengelh@medozas.de>,
	"netfilter-devel@vger.kernel.org" <netfilter-devel@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "Pablo Neira Ayuso" <pablo@netfilter.org>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

>On Mon, May 07, 2012 at 02:57:30PM +0200, Hans Schillstrom wrote:
>> On Monday 07 May 2012 14:22:32 Pablo Neira Ayuso wrote:
>> > On Mon, May 07, 2012 at 02:09:46PM +0200, Hans Schillstrom wrote:
>> > > On Monday 07 May 2012 13:56:12 Pablo Neira Ayuso wrote:
>> > > > On Mon, May 07, 2012 at 11:14:34AM +0200, Hans Schillstrom wrote:
>> > > > > > > We have plenty of rules where just source port mask is zero.
>> > > > > > > and the dest-port-mask is 0xfffc (or 0xffff)
>> > > > > > 
>> > > > > > 0xffff and 0x0000 means on/off respectively.
>> > > > > > 
>> > > > > > Still curious, how can 0xfffc be useful?
>> > > > > 
>> > > > > That's a special case where an appl is using 4 ports.
>> > > > > But in general, have not seen other than "on/off" except for above.
>> > > > 
>> > > > I see. Well I'm fine with this way to switch on/off things, just
>> > > > wanted some clafication.
>> > > > 
>> > > > Still one final thing I'd like to remove before inclusion:
>> > > > 
>> > > > +       union hmark_ports       port_mask;
>> > > > +       union hmark_ports       port_set;
>> > > > +       __u32                   spi_mask;
>> > > > +       __u32                   spi_set;
>> > > > 
>> > > > the spi_mask seems redundant. The port_mask already provides u32 for
>> > > > it.
>> > > 
>> > > No problems, I'll remove it.
>> > 
>> > OK. As a nice side-effect, this will lead to removing the branch that
>> > tests ESP/AH in hmark_set_tuple_ports.
>> >
>> Yes, only check if not ESP or AH to swap src/dst
>
>Do you really that branch? I mean, unless I'm missing anything, swapping
>them shouldn't be a problem.

Well, 
that was just to keep backward compatibility and make my tests happy.
I'll remove them and change my test setup.




