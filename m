From: "David S. Miller" <davem@redhat.com>
Subject: Re: 3c59x
Date: Tue, 10 Jun 2003 10:31:11 -0700 (PDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030610.103111.26297722.davem@redhat.com>
References: <20030610171617.GC1959@gtf.org>
	<200306101731.h5AHVlsG008694@ginger.cmf.nrl.navy.mil>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jgarzik@pobox.com, ak@suse.de, bogdan.costescu@iwr.uni-heidelberg.de,
   hadi@shell.cyberus.ca, ralph+d@istop.com, xerox@foonet.net,
   sim@netnation.com, fw@deneb.enyo.de, netdev@oss.sgi.com,
   linux-net@vger.kernel.org
Return-path: <netdev-bounce@oss.sgi.com>
To: chas@cmf.nrl.navy.mil
In-Reply-To: <200306101731.h5AHVlsG008694@ginger.cmf.nrl.navy.mil>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

   From: chas williams <chas@cmf.nrl.navy.mil>
   Date: Tue, 10 Jun 2003 13:29:54 -0400

   In message <20030610171617.GC1959@gtf.org>,Jeff Garzik writes:
   >Making every IO a conditional branch?  Ug.
   
   you could just test once during driver init and setup an indirection
   to the appropriate function.  its a little better than test and branch.
   
Function calls are actually more expensive, you eat an entry in
the cpu's return address cache.
