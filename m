From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [RFC v3 4/6] bridge: enable root block during device
 registration
Date: Mon, 3 Mar 2014 16:31:59 -0800
Message-ID: <20140303163159.365d763b@nehalam.linuxnetplumber.net>
References: <1393886825-24323-1-git-send-email-mcgrof@do-not-panic.com>
	<1393886825-24323-5-git-send-email-mcgrof@do-not-panic.com>
	<20140303154330.238a20bc@nehalam.linuxnetplumber.net>
	<CAB=NE6VpjebGrqFe7Q4L-uM0rrKitY3fB2kq5qGko+C1Fivm0w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	bridge@lists.linux-foundation.org,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	kvm@vger.kernel.org, xen-devel@lists.xenproject.org
To: "Luis R. Rodriguez" <mcgrof@do-not-panic.com>
Return-path: <bridge-bounces@lists.linux-foundation.org>
In-Reply-To: <CAB=NE6VpjebGrqFe7Q4L-uM0rrKitY3fB2kq5qGko+C1Fivm0w@mail.gmail.com>
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

On Mon, 3 Mar 2014 15:58:50 -0800
"Luis R. Rodriguez" <mcgrof@do-not-panic.com> wrote:

> On Mon, Mar 3, 2014 at 3:43 PM, Stephen Hemminger
> <stephen@networkplumber.org> wrote:
> > Doing this in priv flags bloats what is a limited resource (# of bits).  
> 
> Agreed. I tried to avoid it but saw no other option for addressing
> this during initialization properly without requirng a userspace
> upgrade.

Replacing one Xen hack for another doesn't seem like great progress.
I would rather see an API change as needed because there are other
things like setting STP parameters which might also want to be part
of initial device add.
