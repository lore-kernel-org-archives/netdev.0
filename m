From: Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp>
Subject: Re: [PATCH net-next 0/8] Non-promisc bidge ports support
Date: Thu, 15 May 2014 22:02:25 +0900
Message-ID: <5374BAE1.1050607@lab.ntt.co.jp>
References: <1400080168-16625-1-git-send-email-vyasevic@redhat.com>
	<5374B934.1060902@lab.ntt.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Cc: john.r.fastabend@intel.com, shemminger@vyatta.com,
	bridge@lists.linux-foundation.org, jhs@mojatatu.com, mst@redhat.com
To: Vlad Yasevich <vyasevic@redhat.com>, netdev@vger.kernel.org
Return-path: <bridge-bounces@lists.linux-foundation.org>
In-Reply-To: <5374B934.1060902@lab.ntt.co.jp>
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

(2014/05/15 21:55), Toshiaki Makita wrote:
> (2014/05/15 0:09), Vlad Yasevich wrote:
>> This series adds functionality to the bridge device to enable
>> operations without setting all ports to promiscuous mode.
>>
>> The basic concept is this.  The bridge keeps track of the ports
>> that support learning and flooding packets to unknown destinations.
>> We call these ports auto-discovery ports since they automatically
>> discover who is behind them through learning and flooding.  
>>
>> If flooding and learning are disabled via flags, then the port
>> requires static configuration to tell it which mac addresses
>> are behind it.  This is accomplished through adding of fdbs.
>> These fdbs should be static as dynamic fdbs can expire and systems
>> will become unreachable due to lack of flooding.
> 
> Hi Vlad,
> 
> This is not a comment for this patch set, but I have a question.
> 
> I'm trying to use bridge command to turn off flood/learning but couldn't
> find the corresponding command.
> I'm expecting something like "bridge link set br0 flood/learning".
> 
> Are there any other userspace commands that can set flood/learning flag?
> 

I've just found them in sysfs. Sorry for noise, thanks.

Toshiaki Makita.
