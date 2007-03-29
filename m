From: Roberto Nibali <ratz@drugphish.ch>
Subject: Re: [2.6 patch] the scheduled eepro100 removal
Date: Thu, 29 Mar 2007 10:19:47 +0200
Message-ID: <460B76A3.6040200@drugphish.ch>
References: <20070325145810.GI16477@stusta.de> <460AE997.90509@tmr.com>	 <460AEB85.1020101@intel.com> <460AEF65.8070908@pobox.com> <86802c440703282208m1f79c682q876e4d08d9216cd2@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Jeff Garzik <jgarzik@pobox.com>,
	"Kok, Auke" <auke-jan.h.kok@intel.com>,
	Bill Davidsen <davidsen@tmr.com>, Adrian Bunk <bunk@stusta.de>,
	Andrew Morton <akpm@linux-foundation.org>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	saw@saw.sw.com.sg, Jesse Brandeburg <jesse.brandeburg@intel.com>
To: Yinghai Lu <yinghai.lu@amd.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1751399AbXC2IT7@vger.kernel.org>
In-Reply-To: <86802c440703282208m1f79c682q876e4d08d9216cd2@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

>> Sounds sane to me.  My overall opinion on eepro100 removal is that we're
>> not there yet.  Rare problem cases remain where e100 fails but eepro100
>> works, and it's older drivers so its low priority for everybody.
>>
>> Needs to happen, though...
> 
> It seems that several Tyan Opteron base system that were using IPMI
> add on card.  the IPMI card share intel 100Mhz nic onboard. you need
> to use eepro100 instead of e100 otherwise the e100 will shutdown OOB
> (out of Band) connection for IPMI when shut down the OS.

I find it hard to believe that something as common as IPMI in 
conjunction with the IPMI technology wasn't tested in Intel's lab. From 
my experience with Intel Server boards, onboard IPMI (all offered 
versions) and e100/e1000 NICs, I've never ever experienced any problems 
operating the BMC over the NIC. Also, I don't quite understand you point 
about the "IPMI card sharing the 100Mbit/s NIC" onboard? What exactly is 
shared?

Best regards,
Roberto Nibali, ratz
-- 
echo 
'[q]sa[ln0=aln256%Pln256/snlbx]sb3135071790101768542287578439snlbxq' | dc
