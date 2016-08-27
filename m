From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH] bridge: Fix format string for %ul
Date: Sat, 27 Aug 2016 19:18:16 +0300
Message-ID: <59758948-d899-a32f-12af-a56b8c0da6c1@cogentembedded.com>
References: <1472267428-810527-1-git-send-email-green@linuxhacker.ru>
	<11e50e3c-2e1f-4614-07e3-3bd144af4f94@cogentembedded.com>
	<95BF7F27-59F7-4BDA-941B-BB00C60423A4@linuxhacker.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 8bit
Cc: netdev@vger.kernel.org, bridge@lists.linux-foundation.org,
	"David S. Miller" <davem@davemloft.net>, linux-kernel@vger.kernel.org
To: Oleg Drokin <green@linuxhacker.ru>
Return-path: <bridge-bounces@lists.linux-foundation.org>
In-Reply-To: <95BF7F27-59F7-4BDA-941B-BB00C60423A4@linuxhacker.ru>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/bridge>,
	<mailto:bridge-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/bridge/>
List-Post: <mailto:bridge@lists.linux-foundation.org>
List-Help: <mailto:bridge-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/bridge>,
	<mailto:bridge-request@lists.linux-foundation.org?subject=subscribe>
Sender: bridge-bounces@lists.linux-foundation.org
Errors-To: bridge-bounces@lists.linux-foundation.org
List-Id: netdev.vger.kernel.org

Hello.

On 8/27/2016 6:58 PM, Oleg Drokin wrote:

>>> %ul would print an unsigned value and a letter l,
>>> likely it was %lu that was meant to print the long int,
>>> but in reality the values printed there are just regular signed
>>
>>   Signed? Then you need probably "%d" or "%i"…
>
> They are signed in the struct definition, but in reality they
> designate time, so could not be negative, I imagine?

    That doesn't matter. If the type is signed, it should be printed as signed.
Doesn't gcc complain about the format specifiers not matching the values passed?

>>> ints, so just dropping the l altogether.
>>>
>>> Signed-off-by: Oleg Drokin <green@linuxhacker.ru>
>> [...]

MBR, Sergei
