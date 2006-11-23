From: Ingo Oeser <netdev@axxeo.de>
Subject: Re: 2.6.19-rc6 : Spontaneous reboots, stack overflows - seems to implicate xfs, scsi, networking, SMP
Date: Thu, 23 Nov 2006 14:16:02 +0100
Message-ID: <200611231416.03387.netdev@axxeo.de>
References: <9a8748490611211551v2ebe88fel2bcf25af004c338a@mail.gmail.com> <20061122.201013.112290046.davem@davemloft.net> <20061123070837.GV11034@melbourne.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, jesper.juhl@gmail.com,
	chatz@melbourne.sgi.com, linux-kernel@vger.kernel.org,
	xfs@oss.sgi.com, xfs-masters@oss.sgi.com, netdev@vger.kernel.org,
	linux-scsi@vger.kernel.org
Return-path: <linux-scsi-owner@vger.kernel.org>
To: David Chinner <dgc@sgi.com>
In-Reply-To: <20061123070837.GV11034@melbourne.sgi.com>
Content-Disposition: inline
Sender: linux-scsi-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi there,

David Chinner schrieb:
> If the softirqs were run on a different stack, then a lot of these
> problems would go away (29 of the 35 reported overflows had softirqs
> running) and we'd be much more likely to get XFS to run reliably on
> 4k stacks...

Ok, that seem like another approach. What about putting your allocation slowpath 
in a kernel thread. They might have more stack available.

This is inferior to the complexity reduction suggested from the kernel people,
but if you cannot reduce complexity anymore this might work, too.


Regards

Ingo Oeser
