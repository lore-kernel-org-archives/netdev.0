From: Vlad Yasevich <vyasevic@redhat.com>
Subject: Re: [PATCHv2 net-next 2/2] bridge: Add a flag to control
 unicast packet flood.
Date: Tue, 30 Apr 2013 10:02:30 -0400
Message-ID: <517FCEF6.3060305@redhat.com>
References: <1367256945-25923-1-git-send-email-vyasevic@redhat.com>
	<1367256945-25923-3-git-send-email-vyasevic@redhat.com>
	<20130429164350.11eaaab1@nehalam.linuxnetplumber.net>
Reply-To: vyasevic@redhat.com
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, bridge@lists.linux-foundation.org, mst@redhat.com
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <bridge-bounces@lists.linux-foundation.org>
In-Reply-To: <20130429164350.11eaaab1@nehalam.linuxnetplumber.net>
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

On 04/29/2013 07:43 PM, Stephen Hemminger wrote:
> On Mon, 29 Apr 2013 13:35:45 -0400
> Vlad Yasevich <vyasevic@redhat.com> wrote:
>
>> Add a flag to control flood of unicast traffic.  By default, flood is
>> on and the bridge will flood unicast traffic if it doesn't know
>> the destination.  When the flag is turned off, unicast traffic
>> without an FDB will not be forwarded to the specified port.
>>
>> Signed-off-by: Vlad Yasevich <vyasevic@redhat.com>
>> Reviewed-by: Michael S. Tsirkin <mst@redhat.com>
>>
>
> This a good idea and thank you for doing it. I like that the flag is expressed
> as a positive value (rather than an inverse value like no-flood).
>
> The name BR_UNICAST_FLOOD is too long, just use BR_FLOOD and keep the code
> shorter.
>
> This doesn't apply against current net-next (same problem as first patch).
>
> Also, I am not a fan of having lots of boolean flag variables in normal
> code paths. It ends up reading like PASCAL code. But probably unavoidable in this case.
>

Sorry, I'll rebase and resubmit.  The alternative there is to possibly
flag skb->cb.  Then we wouldn't need to pass the argument around.
If you'd rather I do that, it's easy enough.

Thanks
-vlad
