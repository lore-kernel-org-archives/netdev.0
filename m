From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH net] bridge: notify user space after fdb update
Date: Fri, 30 May 2014 07:32:24 -0700
Message-ID: <20140530073224.2d0baa37@nehalam.linuxnetplumber.net>
References: <1401348436-5187-1-git-send-email-jmaxwell37@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: vyasevic@redhat.com, jpirko@redhat.com, netdev@vger.kernel.org,
	jmaxwell@redhat.com, bridge@lists.linux-foundation.org,
	linux-kernel@vger.kernel.org, davem@davemloft.net
To: Jon Maxwell <jmaxwell37@gmail.com>
Return-path: <bridge-bounces@lists.linux-foundation.org>
In-Reply-To: <1401348436-5187-1-git-send-email-jmaxwell37@gmail.com>
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

On Thu, 29 May 2014 17:27:16 +1000
Jon Maxwell <jmaxwell37@gmail.com> wrote:

> There has been a number incidents recently where customers running KVM have
> reported that VM hosts on different Hypervisors are unreachable. Based on
> pcap traces we found that the bridge was broadcasting the ARP request out
> onto the network. However some NICs have an inbuilt switch which on occasions
> were broadcasting the VMs ARP request back through the physical NIC on the
> Hypervisor. This resulted in the bridge changing ports and incorrectly learning
> that the VMs mac address was external. As a result the ARP reply was directed
> back onto the external network and VM never updated it's ARP cache. This patch
> will notify the bridge command, after a fdb has been updated to identify such
> port toggling.
> 
> Signed-off-by: Jon Maxwell <jmaxwell37@gmail.com>

Acked-by: Stephen Hemminger <stephen@networkplumber.org>
