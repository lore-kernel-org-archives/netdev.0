From: Ben Greear <greearb@candelatech.com>
Subject: Re: Network buffer hang was Re: [PATCH] 2.6 workaround for Athlon/Opteron
 prefetch errata
Date: Thu, 11 Sep 2003 18:46:24 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <3F612570.1010303@candelatech.com>
References: <uqD5.3BI.3@gated-at.bofh.it> <m3iso0arlx.fsf@averell.firstfloor.org> <0a5801c37821$54eb8180$890010ac@edumazet> <20030911051121.GA7751@colin2.muc.de> <0a7701c37829$c4bdef40$890010ac@edumazet> <20030911120956.GB7751@colin2.muc.de> <0b2901c37867$1db399a0$890010ac@edumazet>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "Nakajima, Jun" <jun.nakajima@intel.com>, Andi Kleen <ak@muc.de>,
   linux-kernel@vger.kernel.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: dada1 <dada1@cosmosbay.com>
In-Reply-To: <0b2901c37867$1db399a0$890010ac@edumazet>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

dada1 wrote:
>>>This is not a kernel crash. But total freeze as all memory is used by
>>>network buffers, in no more than 10 seconds.

I believe I have hit this as well, by starting 500kbps streams on 500
vlans at once.  My machine locks so hard that I have not been able to
get any info out of it...but the realtek driver shows and error message
about not being able to allocate any buffers if I ping it....

I was using kernel 2.4.21 or so, and had tcp buffers turned up
quite high.  I have seen this on P-IV and AMD (single Athlon) systems,
as well as a VIA C3.


-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com
