From: Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp>
Subject: Re: [PATCH net] bridge: Fix problems around fdb entries
 pointing to the bridge device
Date: Thu, 4 Aug 2016 19:11:19 +0900
Message-ID: <1b2f2b26-ad21-031c-800b-e894c508713b@lab.ntt.co.jp>
References: <1470276679-5533-1-git-send-email-makita.toshiaki@lab.ntt.co.jp>
	<57A2ED94.2020709@cumulusnetworks.com>
	<ca69126a-3387-7499-c02c-55ba10f0793b@lab.ntt.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, bridge@lists.linux-foundation.org,
	Nikolay Aleksandrov <nikolay@cumulusnetworks.com>,
	"David S. Miller" <davem@davemloft.net>
To: Roopa Prabhu <roopa@cumulusnetworks.com>
Return-path: <bridge-bounces@lists.linux-foundation.org>
In-Reply-To: <ca69126a-3387-7499-c02c-55ba10f0793b@lab.ntt.co.jp>
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

On 2016/08/04 17:15, Toshiaki Makita wrote:
> On 2016/08/04 16:24, Roopa Prabhu wrote:
>> On 8/3/16, 7:11 PM, Toshiaki Makita wrote:
>>> Adding fdb entries pointing to the bridge device uses fdb_insert(),
>>> which lacks various checks and does not respect added_by_user flag.
>>>
>>> As a result, some inconsistent behavior can happen:
>>> * Adding temporary entries succeeds but results in permanent entries.
>>
>> IIRC this is not specific to fdb entries on the bridge device. all temp
>> fdb entries via iproute2 result in permanent entries. thats why 'dynamic'
>> was added.
> 
> Sorry for confusing you, I meant "temp" (i.e., "static") of bridge fdb
> command.
> "temp", "dynamic" and "use" should not result in "permanent".

I probably misread you in my previous reply so the previous answer looks
weird...

What I should have said is:
Other temp fdb entries via iproute2 result in static (== temp), not
permanent.
"dynamic" and "use" should be meant for dynamic entries, not static (temp).

-- 
Toshiaki Makita
