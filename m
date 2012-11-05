From: Doug Goldstein <cardoe@cardoe.com>
Subject: Re: [PATCH] vlan: set sysfs device_type to 'vlan'
Date: Sun, 4 Nov 2012 23:45:56 -0600
Message-ID: <CAFWqQMSes5J1bjUA6NBiWKrjbdUKJkhz-mdNYhGLU-A8cksxZg@mail.gmail.com>
References: <1350885237-12998-1-git-send-email-cardoe@cardoe.com>
	<20121023.023647.2164665243829038911.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: kaber@trash.net, netdev@vger.kernel.org,
	systemd-devel@lists.freedesktop.org, linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20121023.023647.2164665243829038911.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Oct 23, 2012 at 1:36 AM, David Miller <davem@davemloft.net> wrote:
> From: Doug Goldstein <cardoe@cardoe.com>
> Date: Mon, 22 Oct 2012 00:53:57 -0500
>
>> Sets the sysfs device_type to 'vlan' for udev. This makes it easier for
>> applications that query network information via udev to identify vlans
>> instead of using strrchr().
>>
>> Signed-off-by: Doug Goldstein <cardoe@cardoe.com>
>
> You're extremely misguided.  This change, in fact, makes it ten times
> harder for such applications to query such devices.
>
> Because now the application has to decide whether it wants to support
> EVERY EXISTING SYSTEM OUT THERE or not.  Hundreds of millions of Linux
> systems do not provide this attribute.
>
> Applications have to handle the case of not having the 'vlan' device
> type available attribute essentially forever.
>
> So providing it in new kernels provides zero value whatsoever.
>
> I'm not applying this patch, sorry.

Dave,

As others on this thread have discussed there are other merits to the
patch as well. Yes you are correct that netlink is the preferred
method to gather information about network devices but the point was
really to make the sysfs layout more correct a matter of completeness.
As Ben Greear pointed out this would allow shell scripts and other
scripting languages to better detect vlans. Kay pointed out that this
would allow better uevent filters in the future as well. So there are
some merits to this patch. If you'd prefer I can resubmit with a
better commit message entailing the reasons behind it.

Thanks.
-- 
Doug Goldstein
