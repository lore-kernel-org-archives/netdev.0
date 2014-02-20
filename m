From: "Luis R. Rodriguez" <mcgrof@do-not-panic.com>
Subject: Re: [Xen-devel] [RFC v2 1/4] bridge: enable interfaces to
 opt out from becoming the root bridge
Date: Thu, 20 Feb 2014 12:01:25 -0800
Message-ID: <CAB=NE6WKhBJyyUO5o8B53J+F4PqF2PHvvbV3=yS3qs0ZDRKH7Q@mail.gmail.com>
References: <1392433180-16052-1-git-send-email-mcgrof@do-not-panic.com>
	<1392433180-16052-2-git-send-email-mcgrof@do-not-panic.com>
	<20140216105754.63738163@nehalam.linuxnetplumber.net>
	<CAB=NE6WwbOXNLO_Mn42i7y62pEsmDOWd35B621eiJk4iaE3Hfg@mail.gmail.com>
	<1392803559.23084.99.camel@kazak.uk.xensource.com>
	<5304C13F.3030802@citrix.com>
	<CAB=NE6X6Vuo3iib0W-c5cxv0QBpnZtCC0sFyuULugQoEZAbRtg@mail.gmail.com>
	<530600C5.3070107@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Ian Campbell <Ian.Campbell@citrix.com>, kvm@vger.kernel.org,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	bridge@lists.linux-foundation.org,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	Stephen Hemminger <stephen@networkplumber.org>,
	xen-devel@lists.xenproject.org
To: Zoltan Kiss <zoltan.kiss@citrix.com>
Return-path: <bridge-bounces@lists.linux-foundation.org>
In-Reply-To: <530600C5.3070107@citrix.com>
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

On Thu, Feb 20, 2014 at 5:19 AM, Zoltan Kiss <zoltan.kiss@citrix.com> wrote:
> How about this: netback sets the root_block flag and a random MAC by
> default. So the default behaviour won't change, DAD will be happy, and
> userspace don't have to do anything unless it's using netback for STP root
> bridge (I don't think there are too many toolstacks doing that), in which
> case it has to remove the root_block flag instead of setting a random MAC.

:D that's exactly what I ended up proposing too. I mentioned how
xen-netback could do this as well, we'd keep or rename the flag I
added, and then the bridge could would look at it and enable the root
block if the flag is set. Stephen however does not like having the
bridge code look at magic flags for this behavior and would prefer for
us to get the tools to ask for the root block. Let's follow more up on
that thread.

  Luis
