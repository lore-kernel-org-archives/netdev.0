From: Julian Calaby <julian.calaby@gmail.com>
Subject: Re: [PATCH] b43: Increase number of RX DMA slots
Date: Wed, 20 Feb 2013 11:47:54 +1100
Message-ID: <CAGRGNgWZ0qUJSSkjmP8o4VaPRBdN67J=RPy5+45rWaQQXWnWrQ@mail.gmail.com>
References: <20130219.005206.397289032011003833.davem@davemloft.net>
 <AE90C24D6B3A694183C094C60CF0A2F6026B7152@saturn3.aculab.com>
 <5123BCFF.5090408@lwfinger.net> <20130219.131553.787630407148880340.davem@davemloft.net>
 <5123C43D.2020602@lwfinger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: David Miller <davem@davemloft.net>, David.Laight@aculab.com,
	linville@tuxdriver.com, linux-wireless@vger.kernel.org,
	netdev@vger.kernel.org, bittorf@bluebottle.com,
	stable@vger.kernel.org
To: Larry Finger <Larry.Finger@lwfinger.net>
Return-path: <stable-owner@vger.kernel.org>
In-Reply-To: <5123C43D.2020602@lwfinger.net>
Sender: stable-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Larry,

On Wed, Feb 20, 2013 at 5:28 AM, Larry Finger <Larry.Finger@lwfinger.net> wrote:
> On 02/19/2013 12:15 PM, David Miller wrote:
>
>> I understand your constraints, but this is a trivially remotely
>> DoS'able condition even on slow CPU atom laptops.
>>
>> Send an "expansive" full sized frame followed by 300 or so 64-byte UDP
>> packets --> instant hang.
>
>
> Thanks for the suggestion for a test. I think the reset solution should
> survive with only some packet loss, but we will find out.

Is it be possible to increase the number of slots at runtime? Maybe an
even better solution would be to keep the existing number of slots,
and if they run out, reset and increase incrementally to some sensible
maximum value.

Thanks,

-- 
Julian Calaby

Email: julian.calaby@gmail.com
Profile: http://www.google.com/profiles/julian.calaby/
.Plan: http://sites.google.com/site/juliancalaby/
