From: Ricardo C Gonzalez <ricardoz@us.ibm.com>
Subject: Re: [e1000 2.6 10/11] TxDescriptors -> 1024 default
Date: Fri, 12 Sep 2003 13:31:49 -0500
Sender: netdev-bounce@oss.sgi.com
Message-ID: <OFA4E4A95F.4A398E81-ON85256D9F.00651A3A-86256D9F.0065A4E5@us.ibm.com>
References: <3F620C90.5090903@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: hadi@cyberus.ca, "Feldman, Scott" <scott.feldman@intel.com>,
   Jeff Garzik <jgarzik@pobox.com>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
In-Reply-To: <3F620C90.5090903@candelatech.com>
To: Ben Greear <greearb@candelatech.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org




Ben Greear worte:

>I have seen greater packets-per-second throughput when I increase the
TxDescriptor
>ring (and RxDescriptor ring) when using pktgen, which checks for enqueue
errors
>and re-queues as needed.  So, it could help the case where we are running
>at very high sustained speeds (or high packets-per-second rates).

This is exactly the type of test I run(TCP_STREAM tests at very high
sustained speeds). And I saw very good performance improvement when
increasing the TxDescriptors to at least 1024.

I run a network benchmark in this case the data I gathered was on 4 way,
1.45 Ghz systems,  running the benchmark on only one adapter per machine,
point-to-point.


regards,

----------------------------------------------------------------------------------

***  ALWAYS THINK POSITIVE ***

Rick Gonzalez
