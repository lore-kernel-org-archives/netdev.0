From: Paolo Bonzini <pbonzini@redhat.com>
Subject: Re: lost gARP after live migration
Date: Tue, 28 Jun 2011 15:03:08 +0200
Message-ID: <4E09D10C.8010304@redhat.com>
References: <4E09D0A0.1080107@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
	"xen-devel@lists.xensource.com" <xen-devel@lists.xensource.com>
To: Laszlo Ersek <lersek@redhat.com>
Return-path: <xen-devel-bounces@lists.xensource.com>
In-Reply-To: <4E09D0A0.1080107@redhat.com>
List-Unsubscribe: <http://lists.xensource.com/mailman/listinfo/xen-devel>,
	<mailto:xen-devel-request@lists.xensource.com?subject=unsubscribe>
List-Post: <mailto:xen-devel@lists.xensource.com>
List-Help: <mailto:xen-devel-request@lists.xensource.com?subject=help>
List-Subscribe: <http://lists.xensource.com/mailman/listinfo/xen-devel>,
	<mailto:xen-devel-request@lists.xensource.com?subject=subscribe>
Sender: xen-devel-bounces@lists.xensource.com
Errors-To: xen-devel-bounces@lists.xensource.com
List-Id: netdev.vger.kernel.org

On 06/28/2011 03:01 PM, Laszlo Ersek wrote:
> - (Paolo's idea:) watching the "hotplug-status" xenstore node and
> sending a single gARP when the watch fires with "connected". This node
> belongs to the backend xenstore subtree, thus watching it from the guest
> doesn't please the architecture astronaut in me.

Note that watching the backend and reading its information is quite 
common.  In fact, that's how the state of the backend is observed in the 
first place.  Of course you cannot write to the backend tree, but you do 
not have to do that.

Paolo
