From: Hyochang Nam <cannon@postech.ac.kr>
Subject: [Question] SMP for Linux
Date: Thu, 17 Oct 2002 11:29:28 +0900
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20021017112928.B20854@toad.postech.ac.kr>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: niv@us.ibm.com
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Many people helped me to solve the interrupt distribution problem.
We tested the throughput of Layer 3 forwarding on a SMP machine
which equips two Zero proessor(2Ghz). This is our results:
  -------------------------
       SMP    |  No SMP
  -------------------------
    230 Mbps  | 330 Mbps
  -------------------------
We use RedHat Linux 8.0 (which uses Linux Kernel 2.4.18-14) and
two intel Pro1000 Server Adopters. In the table, SMP means we
use the kernel builted for SMP Machine, and "No SMP" means
the kernel builted for single CPU mode. 

I expected that the SMP might show better throughput than "NO SMP"
environments. But, contrary to my expectation, SMP showed poor results. 
I don't know what is my fault in the experiments.

  - Hyochang Nam
