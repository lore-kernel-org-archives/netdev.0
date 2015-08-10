From: "Jason A. Donenfeld" <Jason@zx2c4.com>
Subject: Re: [PATCH v3] xen-apic: Enable on domU as well
Date: Mon, 10 Aug 2015 15:44:07 +0200
Message-ID: <CAHmME9oPC=0rO-UnDfu2UOM6_1dBKA8CV=vHdLnS9Z3OPWtYOQ@mail.gmail.com>
References: <1438879025-27362-1-git-send-email-Jason@zx2c4.com>
	<1439214027-13994-1-git-send-email-Jason@zx2c4.com>
	<55C8AA27.8090207@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Ian Campbell <ian.campbell@citrix.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, xen-devel@lists.xen.org,
	stable@vger.kernel.org
To: David Vrabel <david.vrabel@citrix.com>
Return-path: <stable-owner@vger.kernel.org>
In-Reply-To: <55C8AA27.8090207@citrix.com>
Sender: stable-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Aug 10, 2015 at 3:41 PM, David Vrabel <david.vrabel@citrix.com> wrote:
> On 10/08/15 14:40, Jason A. Donenfeld wrote:
>> It turns out that domU also requires the Xen APIC driver. Otherwise we
>> get stuck in busy loops that never exit, such as in this stack trace:
>
> What's the difference between v3 and v2?

I did some silly things with vim in v2, and there's an extra
semicolon, some other formatting things, and a function is made
unstatic by accident. v3 is what I should have originally sent.
Functionally the same though.
