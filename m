From: Rick Jones <rick.jones2@hp.com>
Subject: Re: [PATCH net-next] tcp: Return error instead of partial read for
 saved syn headers
Date: Mon, 18 May 2015 11:41:40 -0700
Message-ID: <555A3264.3060205@hp.com>
References: <1431974158-28288-1-git-send-email-emunson@akamai.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <edumazet@google.com>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Eric B Munson <emunson@akamai.com>,
	David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1431974158-28288-1-git-send-email-emunson@akamai.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 05/18/2015 11:35 AM, Eric B Munson wrote:
> Currently the getsockopt() requesting the cached contents of the syn
> packet headers will fail silently if the caller uses a buffer that is
> too small to contain the requested data.  Rather than fail silently and
> discard the headers, getsockopt() should return an error and report the
> required size to hold the data.

Is there any chapter and verse on whether a "failed" getsockopt() may 
alter the items passed to it?

rick jones
