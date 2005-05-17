From: Rick Jones <rick.jones2@hp.com>
Subject: Re: [RFC/PATCH] "strict" ipv4 reassembly
Date: Tue, 17 May 2005 13:12:18 -0700
Message-ID: <428A5022.2080606@hp.com>
References: <Pine.LNX.4.61.0505170914130.29021@linux.site>	<200505171531.37167.jheffner@psc.edu> <428A4B74.4050503@us.ibm.com> <200505171605.21093.jheffner@psc.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
In-Reply-To: <200505171605.21093.jheffner@psc.edu>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


> Timer expiration is not dependent on latency, nor is IP ID wrap time.

IP ID wrap time depends on the rate at which IP datgrams are generated.  That 
will depend on latency if the stuff sitting above IP is latency sensitive and/or 
has not increased its "window" (classic TCP, or number of outstanding NFS 
requests ets) to compensate for latency.

So, it is certainly true that one cannot ass-u-me that a high latency path 
cannot have IP ID wrap, but latency can indeed be a factor in how quickly IP IDs 
will wrap in a given situation.

rick jones
