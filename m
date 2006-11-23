From: Arjan van de Ven <arjan@infradead.org>
Subject: Re: 2.6.19-rc6 : Spontaneous reboots, stack overflows - seems to
	implicate xfs, scsi, networking, SMP
Date: Thu, 23 Nov 2006 09:12:25 +0100
Message-ID: <1164269545.31358.771.camel@laptopd505.fenrus.org>
References: <9a8748490611211551v2ebe88fel2bcf25af004c338a@mail.gmail.com>
	 <9a8748490611220458w4d94d953v21f7a29a9f1bdb72@mail.gmail.com>
	 <20061123011809.GY37654165@melbourne.sgi.com>
	 <20061122.201013.112290046.davem@davemloft.net>
	 <20061123043543.GI3078@ftp.linux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, dgc@sgi.com,
	jesper.juhl@gmail.com, chatz@melbourne.sgi.com,
	linux-kernel@vger.kernel.org, xfs@oss.sgi.com,
	xfs-masters@oss.sgi.com, netdev@vger.kernel.org,
	linux-scsi@vger.kernel.org
Return-path: <linux-scsi-owner@vger.kernel.org>
To: Al Viro <viro@ftp.linux.org.uk>
In-Reply-To: <20061123043543.GI3078@ftp.linux.org.uk>
Sender: linux-scsi-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2006-11-23 at 04:35 +0000, Al Viro wrote:
> > I would even say 10 function calls deep to allocate file blocks
> > is overkill, but 22 it just astronomically bad.
> 
> Especially since a large part is due to cxfs...
> -

it's a bit sad to see XFS this crippled in linux due to an external,
proprietary module ;(

-- 
if you want to mail me at work (you don't), use arjan (at) linux.intel.com
Test the interaction between Linux and your BIOS via http://www.linuxfirmwarekit.org

