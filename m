From: Avi Kivity <avi@redhat.com>
Subject: Re: [PATCH] vhost-net: add module alias
Date: Mon, 16 Jan 2012 14:28:35 +0200
Message-ID: <4F1417F3.3050102@redhat.com>
References: <20120110205400.6c1cb306@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, virtualization@lists.linux-foundation.org,
	kvm@vger.kernel.org, "Michael S. Tsirkin" <mst@redhat.com>
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <20120110205400.6c1cb306@nehalam.linuxnetplumber.net>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/virtualization/>
List-Post: <mailto:virtualization@lists.linux-foundation.org>
List-Help: <mailto:virtualization-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=subscribe>
Sender: virtualization-bounces@lists.linux-foundation.org
Errors-To: virtualization-bounces@lists.linux-foundation.org
List-Id: netdev.vger.kernel.org

On 01/11/2012 06:54 AM, Stephen Hemminger wrote:
> By adding the a module alias, programs (or users) won't have to explicitly
> call modprobe. Vhost-net will always be available if built into the kernel.
> It does require assigning a permanent minor number for depmod to work.
> Choose one next to TUN since this driver is related to it.

Statically allocated numbers have to go through lanana, no?

This increases the security exposure and the kernel footprint for hosts
that don't want vhost-net.

-- 
error compiling committee.c: too many arguments to function
