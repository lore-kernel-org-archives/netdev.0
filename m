From: Vlad Yasevich <vyasevic@redhat.com>
Subject: Re: [PATCH v2 net-next 0/6] Allow bridge to function in
 non-promisc mode
Date: Thu, 02 May 2013 13:41:05 -0400
Message-ID: <5182A531.2030900@redhat.com>
References: <1366404770-28523-1-git-send-email-vyasevic@redhat.com>
	<20130502102331.43728912@nehalam.linuxnetplumber.net>
Reply-To: vyasevic@redhat.com
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, bridge@lists.linux-foundation.org, mst@redhat.com
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <bridge-bounces@lists.linux-foundation.org>
In-Reply-To: <20130502102331.43728912@nehalam.linuxnetplumber.net>
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

On 05/02/2013 01:23 PM, Stephen Hemminger wrote:
> Doing research on another problem, I noticed that this would
> break user mode spanning tree (RSTP) code.
>
> The daemon assumes that bridge is promicious mode and therefore
> will receive all link-level multicast packets.
>

Just took another look at RSTP code and I see that's its using
a packet socket with filter to catch STP frames.

Would setting IFF_ALL_MULTI solve the problem?  STP packets
are all multicast.

Thanks
-vlad
