From: "H. Peter Anvin" <hpa@zytor.com>
Subject: Re: Multicast snooping fixes and suggestions
Date: Wed, 23 Feb 2011 20:46:44 -0800
Message-ID: <4D65E2B4.1010501@zytor.com>
References: <1297811961-19249-1-git-send-email-linus.luessing@web.de> <4D65CD81.4070203@zytor.com> <20110224040412.GA25488@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: =?UTF-8?B?TGludXMgTMO8c3Npbmc=?= <linus.luessing@web.de>,
	Stephen Hemminger <shemminger@linux-foundation.org>,
	"David S. Miller" <davem@davemloft.net>,
	bridge@lists.linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Herbert Xu <herbert@gondor.hengli.com.au>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20110224040412.GA25488@gondor.apana.org.au>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 02/23/2011 08:04 PM, Herbert Xu wrote:
> On Wed, Feb 23, 2011 at 07:16:17PM -0800, H. Peter Anvin wrote:
>>
>> Are these packets likely to address that situation (or am I just plain
>> doing something stupid)?
> 
> No these patches deal with IPv6 multicast support in the bridge and
> are not related to your problem.
> 
> If you're using the bridge for virtualisation and you know that
> you don't have a loop in your setup, then one option would be to
> disable STP on your bridge.

Hi,

I have disabled STP on the bridge; it doesn't change the behavior.

	-hpa

-- 
H. Peter Anvin, Intel Open Source Technology Center
I work for Intel.  I don't speak on their behalf.
