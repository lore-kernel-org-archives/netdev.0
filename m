From: Robert Olsson <Robert.Olsson@data.slu.se>
Subject: abysmal e1000 performance (DITR)
Date: Mon, 7 Jun 2004 16:57:30 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <16580.33370.535347.85788@robur.slu.se>
References: <1085700138.30156.1322.camel@tubarao>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: tharbaugh@lnxi.com
In-Reply-To: <1085700138.30156.1322.camel@tubarao>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


Thayne Harbaugh writes:

 > This is a patch to include system load when calculating the DITR.  It
 > only allows the diff/goc ratio to factor into the DITR when the 1 minute
 > load average is above .50.  It appears to work quite well and prevents
 > throttling when the load is below .50 and allows throttling when the
 > load is in excess of .50.

 Hello!

 The experience we had from decorrelating network traffic for use with variable
 interrupt delays etc was that no average based scheme worked at the packet 
 resolution we wanted. 

 The only useful measure we found was using the number of packets received 
 on the RX-ring. You see this used in tulip driver to get a dynamic RX 
 interrupt delay. 

 Cheers.
						--ro
