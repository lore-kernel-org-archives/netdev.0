From: Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp>
Subject: Re: Deleting a dynamic mac entry..
Date: Fri, 26 May 2017 17:15:15 +0900
Message-ID: <45967005-7501-6c96-eb95-f83c5f631277@lab.ntt.co.jp>
References: <CA+N+6-xY7+coc6zFqzP665WMhbGFFMHOfre9wNxRAcSF2Bthzw@mail.gmail.com>
	<e6143108-3eb4-6f6a-c58b-857722f706b9@lab.ntt.co.jp>
	<CA+N+6-xtSgQ4eDN7SBMg43WXEc=6quPNE4L1-3xjLuTMte0DSA@mail.gmail.com>
	<fbf9c273-d326-c26e-593f-ccf139bc0049@lab.ntt.co.jp>
	<CA+N+6-wErt=9XX6u8tPnLbb2DrLqADOnCBn3mDe=qvxCoLCFyg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, bridge@lists.linux-foundation.org
To: Manohar Kumar <forwardinglnx@gmail.com>
Return-path: <bridge-bounces@lists.linux-foundation.org>
In-Reply-To: <CA+N+6-wErt=9XX6u8tPnLbb2DrLqADOnCBn3mDe=qvxCoLCFyg@mail.gmail.com>
Content-Language: en-US
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

On 2017/05/26 14:08, Manohar Kumar wrote:
> On Wed, May 24, 2017 at 6:11 PM, Toshiaki Makita
> <makita.toshiaki@lab.ntt.co.jp> wrote:
>> On 2017/05/25 3:05, Manohar Kumar wrote:
>>> Thanks, Toshiaki.
>>>
>>> What is the right way to set the default_pvid using the bridge command
>>> ? I tried this, which fails..
>>>
>>> root@net-3:~# ip link set dev vxlan0 name untagged type vlan id 0
>>> RTNETLINK answers: Operation not supported
>>> root@net-3:~#
>>>
>>> All the interfaces in the bridge are untagged.
>>
>> # ip link set br0 down
>> # echo 0 > /sys/class/net/br0/bridge/default_pvid
>>
> 
> I have the bridge inside a network namespace. There is no
> /sys/class/net entry for the bridge interface inside the namespace.
> 
> I see online references to this concept of 'tagged' sysfs directories
> to support namespaces. But its not clear how to access the sysfs
> entries for a particular namespace.

Did you remount /sys after entering netns?
If not, remount /sys or use "ip netns" which automatically do it.

> Is there any other way to set the default_pvid for the bridge
> interface inside namespace ?

No, as of 3.19.


Toshiaki Makita
