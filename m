From: SF Markus Elfring <elfring@users.sourceforge.net>
Subject: Re: can: Use common error handling code in vxcan_newlink()
Date: Sat, 28 Oct 2017 21:18:40 +0200
Message-ID: <19ca5f23-fbb0-aaae-bff5-d634af66c264@users.sourceforge.net>
References: <2e600d9a-faec-dd39-08f0-5a7fb260d7ca@users.sourceforge.net>
 <2ab5d794-7a5c-9036-835c-67cfcc541795@hartkopp.net>
 <d3bdd3c0-5a03-dd59-07ca-94b126c67f75@users.sourceforge.net>
 <264b3c2b-8354-5769-639c-ac8d2fcbe630@hartkopp.net>
 <5a76bb36-4ae0-eca2-ae34-69c2bfddb634@users.sourceforge.net>
 <4d612668-5423-4ce3-a4f5-ee394d7ddd21@hartkopp.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Cc: Marc Kleine-Budde <mkl@pengutronix.de>,
        Wolfgang Grandegger <wg@grandegger.com>,
        LKML <linux-kernel@vger.kernel.org>,
        kernel-janitors@vger.kernel.org
To: Oliver Hartkopp <socketcan@hartkopp.net>,
        linux-can@vger.kernel.org, netdev@vger.kernel.org
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <4d612668-5423-4ce3-a4f5-ee394d7ddd21@hartkopp.net>
Content-Language: en-GB
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> If you want to change the semantic of the result check

I am curious if another source code reduction (by the deletion of “ < 0”)
will become acceptable at similar places.


> - this has to done consistently at all rtnl_configure_link() caller sites.

Are there any more functions to consider?


> And not only in vxcan.c

Are you interested in related adjustments for a bigger code base?

Regards,
Markus
