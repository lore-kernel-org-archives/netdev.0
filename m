From: "Feldman, Scott" <scott.feldman@intel.com>
Subject: RE: Submission #3  for S2io 10GbE driver
Date: Tue, 2 Mar 2004 13:47:48 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <C6F5CF431189FA4CBAEC9E7DD5441E010222A08E@orsmsx402.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8bit
Cc: <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
content-class: urn:content-classes:message
To: "Jeff Garzik" <jgarzik@pobox.com>, "Ben Greear" <greearb@candelatech.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

> Let's fix the broken drivers first.

Ok, e100 v3 is same model as tg3, and we think tg3 is correct, so we
think e100 v3 is correct as well.

Ben, e100 v3 probably isn't given you the effect you had with previous
driver versions.  It'll stop the queue and never return a skb (unless we
hit that BUG case).

e1000/ixgb need some work to bring them into this model.

-scott
