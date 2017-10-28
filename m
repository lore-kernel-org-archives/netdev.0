From: SF Markus Elfring <elfring@users.sourceforge.net>
Subject: Re: can: Use common error handling code in vxcan_newlink()
Date: Sat, 28 Oct 2017 20:33:09 +0200
Message-ID: <5a76bb36-4ae0-eca2-ae34-69c2bfddb634@users.sourceforge.net>
References: <2e600d9a-faec-dd39-08f0-5a7fb260d7ca@users.sourceforge.net>
 <2ab5d794-7a5c-9036-835c-67cfcc541795@hartkopp.net>
 <d3bdd3c0-5a03-dd59-07ca-94b126c67f75@users.sourceforge.net>
 <264b3c2b-8354-5769-639c-ac8d2fcbe630@hartkopp.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: Marc Kleine-Budde <mkl@pengutronix.de>,
        Wolfgang Grandegger <wg@grandegger.com>,
        LKML <linux-kernel@vger.kernel.org>,
        kernel-janitors@vger.kernel.org
To: Oliver Hartkopp <socketcan@hartkopp.net>,
        linux-can@vger.kernel.org, netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <264b3c2b-8354-5769-639c-ac8d2fcbe630@hartkopp.net>
Content-Language: en-GB
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> So if you would like to change the if-statement:

It will need a small adjustment for the shown transformation.

I was also unsure if the proposal will work in a single update step.


> 1. Send a patch for vxcan.c to improve the error handling flow

I am going to send a second approach for this update variant.


> 2. Send a separate patch for all rtnl_configure_link() callers to unify the result check
> 
> Step 2 is optional ... and prepare yourself for more feedback ;-)

I am curious on how software development aspects will evolve around
desired error predicates.
Which scope did you have in mind?

Regards,
Markus
