From: Avi Kivity <avi@redhat.com>
Subject: Re: virtio-net zero-copy
Date: Mon, 18 May 2009 17:00:14 +0300
Message-ID: <4A1169EE.3050603@redhat.com>
References: <bd8f29360905180619g3ccee719m268f57e63a88fd4f@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kvm@vger.kernel.org
To: Raju Srivastava <raju.s.linux@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.redhat.com ([66.187.237.31]:37303 "EHLO mx2.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751798AbZEROAQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 18 May 2009 10:00:16 -0400
In-Reply-To: <bd8f29360905180619g3ccee719m268f57e63a88fd4f@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Raju Srivastava wrote:
> Greetings,
>
> Could someone let me know if current virtio-net supports zero-copy? I
> see some discussion here:
> http://thread.gmane.org/gmane.comp.emulators.kvm.devel/28061/
> (copyless virtio net thoughts) and it looks like the copyless
> virtio-net is not supported by KVM yet. 

That is correct.

> If this is true, then is there
> any plan to add the zero copy to the virtio-net?
>   

Yes, but it will be a difficult journey.

> I use KVM in 10G network environment and found the CPU usage is
> saturated when network traffic becomes heavy. The native Linux under
> the same load only consumes less than 10% CPU.
>   

Running the latest guest and host software (both qemu and kernel) will 
improve things somewhat.


-- 
error compiling committee.c: too many arguments to function

