From: Robert Olsson <Robert.Olsson@data.slu.se>
Subject: Re: tulip NAPI patch that works with 2.4.20-pre9 or so?
Date: Tue, 22 Oct 2002 15:55:20 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <15797.22728.683363.412344@robur.slu.se>
References: <Pine.GSO.4.30.0210210826440.17911-100000@shell.cyberus.ca>
	<3DB4EB25.5050706@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 8bit
Cc: jamal <hadi@cyberus.ca>, Robert Olsson <Robert.Olsson@data.slu.se>,
   "'netdev@oss.sgi.com'" <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Ben Greear <greearb@candelatech.com>
In-Reply-To: <3DB4EB25.5050706@candelatech.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


Ben Greear writes:


   In the help file, you suggest this at close:
            for (i=0; i<NR_CPUS; i++) {
 -                  if(adapter->cnt[i]) {
.
   I think the second if should probably be while, ie like this:
            for (i=0; i<NR_CPUS; i++) {
 +                  while(adapter->cnt[i]) {
 
 Thanks!

 Your postings about driver for p430 Phobos 4-port NIC was very confusing. 
 I assume that tulip in 2.4.20-pre9 works even without the tulip-020922.pat.  
 Right?

 Does the board have separate MII-transceivers or is the tulip chips used
 for MII?

 Cheers.

						--ro
