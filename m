From: "David S. Miller" <davem@redhat.com>
Subject: Re: Early SPECWeb99 results on 2.5.33 with TSO on e1000
Date: Thu, 05 Sep 2002 20:56:26 -0700 (PDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20020905.205626.73509740.davem@redhat.com>
References: <1031266115.3d77df4344463@imap.linux.ibm.com>
	<Pine.GSO.4.30.0209052129580.21731-100000@shell.cyberus.ca>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: niv@us.ibm.com, tcw@tempest.prismnet.com, linux-kernel@vger.kernel.org,
   netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: hadi@cyberus.ca
In-Reply-To: <Pine.GSO.4.30.0209052129580.21731-100000@shell.cyberus.ca>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

   From: jamal <hadi@cyberus.ca>
   Date: Thu, 5 Sep 2002 21:47:35 -0400 (EDT)
   
   I am not sure; if he gets a busy system in a congested network, i can
   see the offloading savings i.e i am not sure if the amortization of the
   calls away from the CPU is sufficient enough savings if it doesnt
   involve a lot of retransmits. I am also wondering how smart this NIC
   in doing the retransmits; example i have doubts if this idea is briliant
   to begin with; does it handle SACKs for example? What about
   the du-jour algorithm, would you have to upgrade the NIC or can it be
   taught some new trickes etc etc.
   [also i can see why it makes sense to use this feature only with sendfile;
   its pretty much useless for interactive apps]
   
   Troy, i am not interested in the nestat -s data rather the TCP stats
   this NIC  has exposed. Unless those somehow show up magically in netstat.
   
There are no retransmits happening, the card does not analyze
activity on the TCP connection to retransmit things itself
it's just a simple header templating facility.

Read my other emails about where the benefits come from.

In fact when connection is sick (ie. retransmits and SACKs occur)
we disable TSO completely for that socket.
