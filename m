From: "David S. Miller" <davem@redhat.com>
Subject: Re: Early SPECWeb99 results on 2.5.33 with TSO on e1000
Date: Fri, 06 Sep 2002 00:22:53 -0700 (PDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20020906.002253.32989079.davem@redhat.com>
References: <18563262.1031269721@[10.10.2.3]>
	<20020905.235159.128049953.davem@redhat.com>
	<3D785AE4.A7E3DF2D@zip.com.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Martin.Bligh@us.ibm.com, hadi@cyberus.ca, tcw@tempest.prismnet.com,
   linux-kernel@vger.kernel.org, netdev@oss.sgi.com, niv@us.ibm.com,
   Robert.Olsson@data.slu.se
Return-path: <netdev-bounce@oss.sgi.com>
To: akpm@zip.com.au
In-Reply-To: <3D785AE4.A7E3DF2D@zip.com.au>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

   From: Andrew Morton <akpm@zip.com.au>
   Date: Fri, 06 Sep 2002 00:36:04 -0700

   "David S. Miller" wrote:
   > NAPI is also not the panacea to all problems in the world.
   
   Mala did some testing on this a couple of weeks back.  It appears that
   NAPI damaged performance significantly.

   http://www-124.ibm.com/developerworks/opensource/linuxperf/netperf/results/july_02/netperf2.5.25results.htm

Unfortunately it is not listed what e1000 and core NAPI
patch was used.  Also, not listed, are the RX/TX mitigation
and ring sizes given to the kernel module upon loading.

Robert can comment on optimal settings

Robert and Jamal can make a more detailed analysis of Mala's
graphs than I.
