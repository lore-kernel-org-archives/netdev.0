From: "David S. Miller" <davem@redhat.com>
Subject: Re: 3c59x
Date: Tue, 10 Jun 2003 10:43:05 -0700 (PDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030610.104305.10318104.davem@redhat.com>
References: <20030610.103111.26297722.davem@redhat.com>
	<200306101741.h5AHf8sG008844@ginger.cmf.nrl.navy.mil>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jgarzik@pobox.com, ak@suse.de, bogdan.costescu@iwr.uni-heidelberg.de,
   hadi@shell.cyberus.ca, ralph+d@istop.com, xerox@foonet.net,
   sim@netnation.com, fw@deneb.enyo.de, netdev@oss.sgi.com,
   linux-net@vger.kernel.org
Return-path: <netdev-bounce@oss.sgi.com>
To: chas@cmf.nrl.navy.mil
In-Reply-To: <200306101741.h5AHf8sG008844@ginger.cmf.nrl.navy.mil>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

   From: chas williams <chas@cmf.nrl.navy.mil>
   Date: Tue, 10 Jun 2003 13:39:15 -0400
   
   i was thinking you could do it higher up, like around the hard_start_xmit
   level.  this would create a bit of replicated code, but you could abuse
   the preprocessor a bit i imagine.

3c59x already does this, so now we'd have 4 different copies.
