From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH 1/7] netpoll: shorten carrier detect timeout
Date: Fri, 11 Mar 2005 05:53:16 +0100
Message-ID: <4231243C.1040001@trash.net>
References: <2.454130102@selenic.com> <422A4A38.4040303@trash.net> <20050306002015.GD3120@waste.org> <422A564D.4080809@trash.net> <20050310230117.GP3120@waste.org> <42311FF9.5010007@trash.net> <20050311044246.GT3120@waste.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Jeff Garzik <jgarzik@pobox.com>, netdev@oss.sgi.com,
        Jeff Moyer <jmoyer@redhat.com>
To: Matt Mackall <mpm@selenic.com>
In-Reply-To: <20050311044246.GT3120@waste.org>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Matt Mackall wrote:
> On Fri, Mar 11, 2005 at 05:35:05AM +0100, Patrick McHardy wrote:
> 
>>>So I'm going to change it from "flaky" to "untrustworthy" and add a
>>>comment.
>>
>>Why don't you trust an instaneously available carrier? Any
>>reason to assume there will be false positives?
> 
> 
> Because I had reports of people losing all their boot messages until
> this logic was added (about a year ago now?). I don't remember which
> NICs were implicated, but some apparently report carrier is always
> available.

If this problem is not common, I think it would be better to make
this behaviour dependant on a boot parameter instead of forcing
everyone to wait for 4s. Additionally you could have a blacklist
of flaky NICs.

Regards
Patrick
