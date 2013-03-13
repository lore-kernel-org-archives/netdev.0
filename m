From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH net-next 0/4] Allow bridge to function in
 non-promisc mode
Date: Wed, 13 Mar 2013 09:09:21 -0700
Message-ID: <20130313090921.05dbf6e2@nehalam.linuxnetplumber.net>
References: <1363139126-13396-1-git-send-email-vyasevic@redhat.com>
	<473541363155743@web2d.yandex.ru> <51406D2D.30703@redhat.com>
	<20130313083932.6483876f@nehalam.linuxnetplumber.net>
	<51409F24.3070305@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"bridge@lists.linux-foundation.org" <bridge@lists.linux-foundation.org>,
	"Oleg A. Arkhangelsky" <sysoleg@yandex.ru>
To: vyasevic@redhat.com
Return-path: <bridge-bounces@lists.linux-foundation.org>
In-Reply-To: <51409F24.3070305@redhat.com>
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

On Wed, 13 Mar 2013 11:45:40 -0400
Vlad Yasevich <vyasevic@redhat.com> wrote:

> On 03/13/2013 11:39 AM, Stephen Hemminger wrote:
> > On Wed, 13 Mar 2013 08:12:29 -0400
> > Vlad Yasevich <vyasevic@redhat.com> wrote:
> >
> >> On 03/13/2013 02:22 AM, "Oleg A. Arkhangelsky" wrote:
> >>>
> >>>
> >>> 13.03.2013, 05:45, "Vlad Yasevich" <vyasevic@redhat.com>:
> >>>
> >>>> The series adds an ability for the bridge to function in non-promiscuous mode.
> >>>
> >>> What is the practical applications for such setup? In other words,
> >>> in which cases I would want to put bridge into non-promiscuous
> >>> mode and specify some uplink ports?
> >>>
> >>
> >> On of the applications would be when bridge is an edge device servicing
> >> a VM deployment.  Each of the VMs knows the mac address that the guest
> >> has and may program that mac onto the uplinks.
> >
> > Why wouldn't that environment just use macvlan?
> > Is it because changing libvirt is harder than changing the kernel?
> >
> 
> No, because macvlan has a drawback that it doesn't easily let guests 
> talk to the host.  Bridge is still most commonly used for just that reason.
> 
> -vlad

Maybe fixing that with a flag to macvlan would be easier?
