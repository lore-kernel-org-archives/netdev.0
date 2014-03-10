From: Cong Wang <cwang@twopensource.com>
Subject: Re: [PATCH 1/2] bridge: multicast: add sanity check for
	general query destination
Date: Mon, 10 Mar 2014 12:01:16 -0700
Message-ID: <CAHA+R7O1XNRhY_psPhtP0JLxFhXbVE=bQc2J=RcFAKvYV6tMgQ@mail.gmail.com>
References: <1394422786-1683-1-git-send-email-linus.luessing@web.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Cc: netdev <netdev@vger.kernel.org>, Florian Westphal <fwestpha@redhat.com>,
	bridge@lists.linux-foundation.org,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	Stephen Hemminger <stephen@networkplumber.org>,
	Jan Stancek <jstancek@redhat.com>
To: =?ISO-8859-1?Q?Linus_L=FCssing?= <linus.luessing@web.de>
Return-path: <bridge-bounces@lists.linux-foundation.org>
In-Reply-To: <1394422786-1683-1-git-send-email-linus.luessing@web.de>
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

On Sun, Mar 9, 2014 at 8:39 PM, Linus L=FCssing <linus.luessing@web.de> wro=
te:
> +       is_general_query =3D group && ipv6_addr_any(group) ? true : false=
;
> +

Just "is_general_query =3D group && ipv6_addr_any(group);" should be okay.
