From: Robert Olsson <Robert.Olsson@data.slu.se>
Subject: Performance problem with route cache ?
Date: Thu, 20 Nov 2003 13:37:49 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <16316.46493.7576.116171@robur.slu.se>
References: <02da01c3af54$c1f37f20$890010ac@edumazet>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: "dada1" <dada1@cosmosbay.com>
In-Reply-To: <02da01c3af54$c1f37f20$890010ac@edumazet>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org



dada1 writes:
 > Hi all
 > 
 > I'm doing some oprofile on a bi athlon, linux-2.6.0-test8 kernel, (with a
 > copybreak intel e1000 patch, because the machine receives a lot of small (<
 > 30 bytes) messages)

 Does the copybreak help? I tested copybreak long time ago and saw no gain
 from it. Do you have pointer to the patch?

 > It seems the route cache may/should be tuned, but I dont know how.
 
 Tuning is not an easy task and not necessarily you will gain anything,
 It fully depends on your input traffic but it seems your system has a 
 lot of dst entries. Which would cause a lot linear search. Packets per 
 flow and no of parallel flows should be of interest for you. rtstat can 
 give you a better feeling of incoming routing load.
 
 Is 10kpkts/s the max performance?

 Cheers.
						--ro
