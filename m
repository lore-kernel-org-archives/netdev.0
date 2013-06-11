From: Markos Chandras <markos.chandras@gmail.com>
Subject: Re: [PATCH] drivers/net/ethernet/3com: Drop EISA dependency from VORTEX
Date: Tue, 11 Jun 2013 21:29:03 +0100
Message-ID: <CAG2jQ8jcZGW=9Tsb9c+YVEa0dPtgABJpYxWghdWp0-GGHYoQ2Q@mail.gmail.com>
References: <1370962642-12097-1-git-send-email-markos.chandras@imgtec.com>
 <51B75088.8050800@windriver.com> <CAG2jQ8hACp_iGEXR7rXKR3sydK4O=y0paeh1FFgH2UisxWVxVA@mail.gmail.com>
 <51B78594.5050903@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Markos Chandras <markos.chandras@imgtec.com>,
	linux-kernel@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Paul Gortmaker <paul.gortmaker@windriver.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <51B78594.5050903@windriver.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 11 June 2013 21:16, Paul Gortmaker <paul.gortmaker@windriver.com> wrote:
>>
>> Hi Paul,
>>
>> The driver does not seem to build if you only have EISA=y and PCI=n.
>> Does this driver really support EISA only
>
> Yes.  Not that anyone really probably cares anymore.  EISA is dead.
>
>> configurations? Reading the code it seems to me that the PCI support
>> is mandatory for the driver to build and work.
>
> Oh really?  Having PCI disabled seems fine on today's net-next tree
> from what I see below:

Hi Paul,

Ok I guess I was wrong then.

--
Regards,
Markos Chandras
