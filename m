From: Richard Gooch <rgooch@ras.ucalgary.ca>
Subject: Poor gige performance with 2.4.20-pre*
Date: Sat, 28 Sep 2002 16:57:55 -0600
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200209282257.g8SMvta32527@vindaloo.ras.ucalgary.ca>
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

  Hi, all. For a while now I've noticed poor performance with gige
cards under 2.4.19 and 2.4.20-pre*. At first I thought it was because
of the cheap-ass Addtron cards I bought (these use the ns83820 chip).
But now that the Intel E1000 cards are pretty cheap too, I've grabbed
a couple (part number: PWLA8390MT) and see the same problem. In fact,
the E1000 cards are no better than the Addtron cards. I'm using the
D-Link DGS-1008T 8-port gige switch. MTU=1500 bytes.

The basic test I do is to send 100 MB over a TCP connection from one
machine to the other. The results are:

Dual PIII 450 MHz -> Dual Athalon 1.6 GHz yields 58 MB/s
Dual Athalon 1.6 GHz -> Dual PIII 450 MHz yields 23 MB/s

This is quite a bit less than what gige is supposed to give. Is this
expected?

				Regards,

					Richard....
Permanent: rgooch@atnf.csiro.au
Current:   rgooch@ras.ucalgary.ca
