From: Oliver Hartkopp <socketcan@hartkopp.net>
Subject: Re: can: Use common error handling code in vxcan_newlink()
Date: Sat, 28 Oct 2017 21:04:46 +0200
Message-ID: <4d612668-5423-4ce3-a4f5-ee394d7ddd21@hartkopp.net>
References: <2e600d9a-faec-dd39-08f0-5a7fb260d7ca@users.sourceforge.net>
 <2ab5d794-7a5c-9036-835c-67cfcc541795@hartkopp.net>
 <d3bdd3c0-5a03-dd59-07ca-94b126c67f75@users.sourceforge.net>
 <264b3c2b-8354-5769-639c-ac8d2fcbe630@hartkopp.net>
 <5a76bb36-4ae0-eca2-ae34-69c2bfddb634@users.sourceforge.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Marc Kleine-Budde <mkl@pengutronix.de>,
        Wolfgang Grandegger <wg@grandegger.com>,
        LKML <linux-kernel@vger.kernel.org>,
        kernel-janitors@vger.kernel.org
To: SF Markus Elfring <elfring@users.sourceforge.net>,
        linux-can@vger.kernel.org, netdev@vger.kernel.org
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <5a76bb36-4ae0-eca2-ae34-69c2bfddb634@users.sourceforge.net>
Content-Language: en-US
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 10/28/2017 08:33 PM, SF Markus Elfring wrote:
>> So if you would like to change the if-statement:
> 
> It will need a small adjustment for the shown transformation.
> 
> I was also unsure if the proposal will work in a single update step.
> 
> 
>> 1. Send a patch for vxcan.c to improve the error handling flow
> 
> I am going to send a second approach for this update variant.

Ok.

> 
>> 2. Send a separate patch for all rtnl_configure_link() callers to unify the result check
>>
>> Step 2 is optional ... and prepare yourself for more feedback ;-)
> 
> I am curious on how software development aspects will evolve around
> desired error predicates.
> Which scope did you have in mind?

Oh, I don't have any scope in mind.

I just wanted to make clear that I don't want to have a different kind 
of result handling in vxcan.c and veth.c

So if you suggest to simplify the error flow that would be ok for me.

If you want to change the semantic of the result check - this has to 
done consistently at all rtnl_configure_link() caller sites. And not 
only in vxcan.c

That's what I have in mind.

Regards,
Oliver

