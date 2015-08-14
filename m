From: Markos Chandras <markos.chandras@imgtec.com>
Subject: Re: [PATCH 6/6] MIPS: net: BPF: Introduce BPF ASM helpers
Date: Fri, 14 Aug 2015 08:59:36 +0100
Message-ID: <20150814075936.GA16737@mchandras-linux.le.imgtec.org>
References: <1433415376-20952-1-git-send-email-markos.chandras@imgtec.com>
 <1433415376-20952-7-git-send-email-markos.chandras@imgtec.com>
 <20150813204246.GA24857@aurel32.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
To: <linux-mips@linux-mips.org>, <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	Alexei Starovoitov <ast@plumgrid.com>,
	Daniel Borkmann <dborkman@redhat.com>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	<linux-kernel@vger.kernel.org>, <debian-kernel@lists.debian.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20150813204246.GA24857@aurel32.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Aug 13, 2015 at 10:42:46PM +0200, Aurelien Jarno wrote:
> 
> This patch relies on R2 instructions, and thus the Linux kernel fails to
> build when targetting non-R2 CPUs. See for example:
> 
> https://buildd.debian.org/status/fetch.php?pkg=linux&arch=mipsel&ver=4.2%7Erc6-1%7Eexp1&stamp=1439480000
> 
> -- 
> Aurelien Jarno                          GPG: 4096R/1DDD8C9B
> aurelien@aurel32.net                 http://www.aurel32.net
Hi,

I think Ralf may have a fix for R1 cores but I am not sure about the status of
that patch. Ralf?

-- 
markos
