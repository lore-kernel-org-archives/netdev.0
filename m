From: Alan Cox <alan@lxorguk.ukuu.org.uk>
Subject: Re: The ultimate TOE design
Date: Fri, 17 Sep 2004 15:15:28 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1095430526.26088.1.camel@localhost.localdomain>
References: <4148991B.9050200@pobox.com>
	 <OF8783A4F6.D566336C-ON88256F10.006E51CE-88256F10.006EDA93@us.ibm.com>
	 <311601c90409162346184649eb@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: David Stevens <dlstevens@us.ibm.com>, Netdev <netdev@oss.sgi.com>,
        leonid.grossman@s2io.com,
        Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
Return-path: <netdev-bounce@oss.sgi.com>
To: Eric Mudama <edmudama@gmail.com>
In-Reply-To: <311601c90409162346184649eb@mail.gmail.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Gwe, 2004-09-17 at 07:46, Eric Mudama wrote:
> On Wed, 15 Sep 2004 14:11:04 -0600, David Stevens <dlstevens@us.ibm.com> wrote:
> > Why don't we off-load filesystems to disks instead?
> 
> Disks have had file systems on them since close to the beginning...

This is essentially the path Lustre is taking. Although it seems you
don't want to have a "full" file system on the disk since you lose to
much flexibility, instead you want the ability to allocate by handle
giving hints about locality and use.

People have also tried full file system offload - intel for example
prototyped an I2O file system class, and adaptec clearly were trying
this out on aacraid development from looking at the public headers.

Alan
