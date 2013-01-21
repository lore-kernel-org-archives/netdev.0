From: Tom St Denis <tstdenis@elliptictech.com>
Subject: Re: IPsec AH use of ahash
Date: Sun, 20 Jan 2013 19:46:44 -0500 (EST)
Message-ID: <1675719618.94034.1358729204255.JavaMail.root@elliptictech.com>
References: <8b7b5c2c-1e9f-4390-8492-a21cf8566d55@email.android.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	David Dillow <dave@thedillows.org>
To: Alan Cox <alan@lxorguk.ukuu.org.uk>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <8b7b5c2c-1e9f-4390-8492-a21cf8566d55@email.android.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



----- Original Message -----
> From: "Alan Cox" <alan@lxorguk.ukuu.org.uk>
> To: "Tom St Denis" <tstdenis@elliptictech.com>, "David Dillow" <dave@thedillows.org>
> Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
> Sent: Sunday, 20 January, 2013 3:30:49 PM
> Subject: Re: IPsec AH use of ahash
> 
> Look at it from the kernel end. What happens if your change shows up
> bugs on another architecture or has a flaw. It works for you now but
> you plan to dump and run. That's not a viable long term development
> model for upstream.

Alan, I'm really not trying to be rude but if you look at the depth of the patch I was submitting ... it's not architecture specific, it's 90% copied from another source file that is currently in the tree, I have actually tested it on x86_32/arm already as it is, etc.  I agree that more core pieces of architecture specific code would require tighter scrutiny but this is hardly the case here. 

> The licence allows you to do it, and other parties who care more to
> pick it up and run with it. Unless someone does however it's just a
> burden. If nobody wants it upstream enough better it stays out
> perhaps - if the call is wrong eventually other people will care
> enoug to share the work. If not you get to pick between doing the
> extra or re-porting your code to new releases

Realistically, the CryptoAPI maintainers should have added CMAC long ago.  I mean they sought fit to add non-standard modes like VMAC or Serpent [or Twofish or ...] but not a NIST standard like CMAC which is used in RFCs for IPsec [among other things]?  Are they writing crypto for Kernel users or is this their pet project where they get to hack together random bits of ciphering what not for their own amusement?

Sure few people are clamouring to use CMAC over say HMAC for MAC generation but it is a standard and it's prevalent enough that supporting it is a good idea.

Forcing me to go through a new testing cycle just because you'd prefer

if (expr)
   foo;

Instead of 

if (expr) {
   foo;
}

or 

err = expr;
if (err) ...

instead of 

if ((err = expr)) ...

is not a good use of anyones time.  And it's hypocritical given that I sourced that coding style from code that is already in the kernel.

Tom
