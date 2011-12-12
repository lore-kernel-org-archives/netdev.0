From: Wolfgang Grandegger <wg@grandegger.com>
Subject: Re: [PATCH net-next v2 2/4] can: cc770: add legacy ISA bus driver
 for the CC770 and AN82527
Date: Mon, 12 Dec 2011 12:55:43 +0100
Message-ID: <4EE5EBBF.6080007@grandegger.com>
References: <1322214204-1121-1-git-send-email-wg@grandegger.com> <1322214204-1121-3-git-send-email-wg@grandegger.com> <4ED0FEC5.3070108@hartkopp.net> <4ED34CAD.7040000@essax.com> <4ED351A8.8000102@grandegger.com> <4ED37885.8080909@essax.com> <4ED3B198.2040308@hartkopp.net> <4ED4A2EC.40103@grandegger.com> <4EDBC05D.8070109@essax.com> <4EDBC25D.50405@grandegger.com> <4EDE8435.5080100@essax.com> <4EDF6D54.2060503@grandegger.com> <4EE1E26B.6090308@grandegger.com> <4EE4F76E.3000506@essax.com> <4EE5C824.2050704@grandegger.com> <4EE5E321.8050104@essax.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Oliver Hartkopp <socketcan@hartkopp.net>, netdev@vger.kernel.org,
	linux-can@vger.kernel.org, socketcan-users@lists.berlios.de,
	IreneV <boir1@yandex.ru>,
	Stanislav Yelenskiy <stanislavelensky@yahoo.com>
To: info@essax.com
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <4EE5E321.8050104@essax.com>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 12/12/2011 12:18 PM, Wolfgang Zarre wrote:
> Hello Wolfgang,
>> Hi Wolfgang,
>>
>> On 12/11/2011 07:33 PM, Wolfgang Zarre wrote:
>>> Hello Wolfgang,
>>>> On 12/07/2011 02:42 PM, Wolfgang Grandegger wrote:
>>>>> Hi Wolfgang,
>>>>>
>>>>> On 12/06/2011 10:08 PM, Wolfgang Zarre wrote:
>> ...
>>>>>> Let me know if You need more or some other tests.
>>>>>
>>>>> You could provoke some state changes or bus-off conditions to see
>>>>> if the
>>>>> berr-counter shows reasonable results. I'm currently consolidating and
>>>>> unifying error state and bus-off handling. Would be nice if you
>>>>> could do
>>>>> some further tests when I have the patches ready...
>>>>
>>>> I just pushed the mentioned modifications to the "devel" branch of my
>>>> "wg-linux-can-next" [1] repository. You can get it as shown below:
>>>>
>>>>     $ git clone --reference=<some-recent-net-next-tree>   \
>>>>        
>>>> git://gitorious.org/~wgrandegger/linux-can/wg-linux-can-next.git
>>>>     $ git checkout -b devel devel
>>>>
>>>> [1] https://gitorious.org/~wgrandegger/linux-can/wg-linux-can-next
>>>>
>>>> Wolfgang.
>>>
>>> OK, I was trying so far and You will find below the results.
>>> Just FYI the states on the PLC side couldn't be verified because the
>>> function
>>> provided by the manufacturer is not working at all and CAN analyser
>>> was not
>>> available.
>>>
>>> We are running CANopen and therefore the PLC will send automatically a
>>> heartbeat.
>>>
>>> I produced the bus-off state through a short circuit between L/H
>>> which was
>>> working as expected.
>>>
>>> A bit odd was that on the second try I had to reload the module
>>> because a ip down/up was not enough.
>>
>> Oops, not good.
>>
> 
> But might be in connection with the strange behaviour of the PLC.

It's a bug! netif_start_queue is missing at the end of the open
function. Got lost some how. I have just updated (rebased!) my
wg-linux-can-next repository.

Wolfgang.
