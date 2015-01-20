From: Fernando Gont <fgont@si6networks.com>
Subject: Re: [PATCH net] ipv6: stop sending PTB packets for MTU < 1280
Date: Tue, 20 Jan 2015 01:52:35 -0300
Message-ID: <54BDDF13.9010007@si6networks.com>
References: <1421357665-2804-1-git-send-email-hagen@jauu.net>	<1421675722.32277.3.camel@stressinduktion.org>	<CAPh34mc3T7W81J_NjMkHvQpjad1gTM3j99gnX8x8jnKvh2TBDg@mail.gmail.com>	<20150119.145058.954790496532942109.davem@davemloft.net>	<1421697951.13047.9.camel@stressinduktion.org>	<CAPh34mc_5XPqC5_Xdx3gZScfnqtZC7b9JPGp4FfWVh+PvSfb3w@mail.gmail.com> <CAOp4FwRdRai8tL5koFvHKr0P=dR6MgT5ZLtMg85drt6LTzYNrQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Cc: Hannes Frederic Sowa <hannes@stressinduktion.org>,
	David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>, stable@vger.kernel.org
To: Loganaden Velvindron <loganaden@gmail.com>,
	Hagen Paul Pfeifer <hagen@jauu.net>
Return-path: <stable-owner@vger.kernel.org>
In-Reply-To: <CAOp4FwRdRai8tL5koFvHKr0P=dR6MgT5ZLtMg85drt6LTzYNrQ@mail.gmail.com>
Sender: stable-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi, Loganaden,

On 01/20/2015 01:02 AM, Loganaden Velvindron wrote:
> 
> Last time I was inquiring about depracated atomic fragments, people
> were concerned that there wasn't enough practical data to decide
> whether to go forward or not.

What kind of practical data?

FWIW,
<https://tools.ietf.org/id/draft-ietf-6man-deprecate-atomfrag-generation-00.txt>
seems to be good enough when it comes to reasons for deprecating them.


Besides, please check Section 5.2 of
<http://www.ietf.org/id/draft-gont-v6ops-ipv6-ehs-in-real-world-01.txt>
-- my "connection" to kernel.org was vulnerable to such attack.



> Would a sysctl with it turned on by default be a good option, until we
> are 100% sure ?

<https://tools.ietf.org/id/draft-ietf-6man-deprecate-atomfrag-generation-00.txt>
 was adopted by the 6man wg last November. While the I-D is not ready an
RFC, and there might be minor modifications, it seems that there's
agreement in not generating atomic fragments.

If you do want to have a sysctl for this, please make it default to "off".

Thanks!

Best regards,
-- 
Fernando Gont
SI6 Networks
e-mail: fgont@si6networks.com
PGP Fingerprint: 6666 31C6 D484 63B2 8FB1 E3C4 AE25 0D55 1D4E 7492
