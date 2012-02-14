From: Rick Jones <rick.jones2@hp.com>
Subject: Re: [patch net-next] cxgb3: update firmware version
Date: Tue, 14 Feb 2012 10:17:27 -0800
Message-ID: <4F3AA537.4050700@hp.com>
References: <20120213202846.631.30806.stgit@speedy5.asicdesigners.com> <1329165817.2092.62.camel@shinybook.infradead.org> <4F398303.1030606@chelsio.com> <1329184754.3048.33.camel@deadeye> <4F39E7C9.20901@chelsio.com> <1329196116.3048.66.camel@deadeye> <4F39F75D.6030107@chelsio.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Divy Le Ray <divy@chelsio.com>,
	David Woodhouse <dwmw2@infradead.org>, davem@davemloft.net,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Steve Wise <swise@opengridcomputing.com>, nhorman@tuxdriver.com
To: Ben Hutchings <ben@decadent.org.uk>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <4F39F75D.6030107@chelsio.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

What does an end-user/customer see and do?  When they are told that 
version the firmware, specified down to the fix level, fixes a problem 
they are having, how will they know that firmware blob filename 
drvfw-X.bin on a download/archive site has that fix?  Yes, the support 
folks can say "It is the drcfw-X.bin file which is 12345 bytes in size 
with the MD5sum of <blah> but the principle of the telephone game 
dictates the size and/or MD5sum information will drop as "the word" 
passes from one person to another. And one cannot run 
ethtool_ops::get_drvinfo against a website.  Two versions may indeed be 
"compatible" in terms of interfaces, but they won't be identical in 
terms of desirability.  As such, for them to be contained in files with 
identical names just seems like asking for confusion.

Firmware is something of a tiny kernel no?  Would we have everyone name 
vmlinux files with just a major number?

rick jones
