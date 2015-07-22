From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
Subject: Re: [PATCH net-next] bridge: mcast: when multicast is
 disabled flush the groups
Date: Wed, 22 Jul 2015 20:01:45 +0200
Message-ID: <55AFDA89.1080304@cumulusnetworks.com>
References: <1437560929-25827-1-git-send-email-nikolay@cumulusnetworks.com>
	<CAHA+R7PTV5aTk2JyaaCQ1awi_Cwz+jzA4tv9n2nEvaFxhuD0Pg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	"bridge@lists.linux-foundation.org" <bridge@lists.linux-foundation.org>,
	David Miller <davem@davemloft.net>
To: Cong Wang <cwang@twopensource.com>
Return-path: <bridge-bounces@lists.linux-foundation.org>
In-Reply-To: <CAHA+R7PTV5aTk2JyaaCQ1awi_Cwz+jzA4tv9n2nEvaFxhuD0Pg@mail.gmail.com>
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

On 07/22/2015 07:03 PM, Cong Wang wrote:
> On Wed, Jul 22, 2015 at 3:28 AM, Nikolay Aleksandrov
> <nikolay@cumulusnetworks.com> wrote:
>> From: Satish Ashok <sashok@cumulusnetworks.com>
>>
>> Once multicast gets disabled we should flush the groups.
>> Example:
>> # bridge mdb add dev br0 port eth3 grp 239.0.0.1
>> # bridge mdb
>> dev br0 port eth3 grp 239.0.0.1 temp
>> # echo 0 > multicast_snooping
>> # bridge mdb
> 
> Why? Why we can't save the mdb config for a mcast snooping flip?
> 

Right, I've discussed this with my colleagues and we think this doesn't have any
value for upstream and shouldn't have been sent which is bad judgment on my side.
It actually makes things worse because it removes the user's permanent entries on
snooping disable and it may happen automatically by hash exhaustion.

Anyway, please drop this patch and sorry for the noise, I should've given this
change more thought.

Thanks,
 Nik
