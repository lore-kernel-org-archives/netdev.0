From: "Jeff Kirsher" <jeffrey.t.kirsher@intel.com>
Subject: Re: [PATCH -net-next 1/4] firmware: convert e100
	driver to request_firmware()
Date: Wed, 7 Jan 2009 10:49:38 -0800
Message-ID: <9929d2390901071049i73027b13j8910f6c6dcd9ce92@mail.gmail.com>
References: <9929d2390812301433pae01ea4g5bfdef6d4d4c7a9c@mail.gmail.com>
	<20090104.160611.252248503.davem@davemloft.net>
	<9929d2390901041820h4cf51e2h3612108c516b6869@mail.gmail.com>
	<20090104.213402.12464178.davem@davemloft.net>
	<9929d2390901071023s590f439fre15696786f098b81@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org,
	jaswinder@infradead.org, linux-next@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: "David Miller" <davem@davemloft.net>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <9929d2390901071023s590f439fre15696786f098b81@mail.gmail.com>
Content-Disposition: inline
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

On Wed, Jan 7, 2009 at 10:23 AM, Jeff Kirsher
<jeffrey.t.kirsher@intel.com> wrote:
> On Sun, Jan 4, 2009 at 9:34 PM, David Miller <davem@davemloft.net> wrote:
>> From: "Jeff Kirsher" <jeffrey.t.kirsher@intel.com>
>> Date: Sun, 4 Jan 2009 18:20:24 -0800
>>
>>> On Sun, Jan 4, 2009 at 4:06 PM, David Miller <davem@davemloft.net> wrote:
>>> > From: "Jeff Kirsher" <jeffrey.t.kirsher@intel.com>
>>> > Date: Tue, 30 Dec 2008 14:33:36 -0800
>>> >
>>> >> Please hold off on committing, until we have had ample time to do some
>>> >> regression testing.  While this patch may have been in linux-next,
>>> >> this is the first we have seen of it.
>>> >>
>>> >> I am concerned that IPMI traffic will be adversely affected by this patch.
>>> >
>>> > Status please?
>>> > --
>>>
>>> The only testing left to do is to make sure that ICH devices still
>>> work and to make sure the IPMI traffic is not affected by this patch.
>>> All other testing looks good.  I am sorry that I have been slow to
>>> give status, the holiday's have put a strain on available resources.
>>
>> Ok, thanks for the update.
>> --
>>
>
> So here is the latest testing update...
>
> The only testing that we were not able to do was the IPMI testing,
> because of the lack of resources.  All other testing passed.
>
> While all other testing passed, I am concerned about not being able to
> test whether or not this change affects the ability to pass IPMI
> traffic.  I am not sure if the "gain" of using request_firmware() out
> weighs the potential risk that IPMI traffic may be broken with this
> patch.  I guess I wondering what the gain is in using the
> request_firmware() function?
>
> From past experience with IPMI traffic and the e100, the loading of
> the microcode in the correct manner greatly affected whether IPMI
> traffic would pass or not.
>
> --
> Cheers,
> Jeff
>

Removed bad email address (linux.nics@intel.com) from CC.  That email
address is no longer valid.

-- 
Cheers,
Jeff

------------------------------------------------------------------------------
Check out the new SourceForge.net Marketplace.
It is the best place to buy or sell services for
just about anything Open Source.
http://p.sf.net/sfu/Xq1LFB
