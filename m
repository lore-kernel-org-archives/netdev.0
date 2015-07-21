From: Pravin Shelar <pshelar-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH v2] openvswitch: allocate nr_node_ids
 flow_stats instead of num_possible_nodes
Date: Tue, 21 Jul 2015 11:29:56 -0700
Message-ID: <CALnjE+rBtWhiGdjEi4cANpuu54muv9DtO=q_37eZ70Ou2FuDFw@mail.gmail.com>
References: <20150721162418.GM38815@linux.vnet.ibm.com>
 <1437500193-10255-1-git-send-email-chris.j.arges@canonical.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: "dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org" <dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>, benh-XVmvHMARGAS8U2dJNN8I7kB+6BGkLq7r@public.gmane.org,
 nacc-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, LKML <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
 linux-numa-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
 linuxppc-dev-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org, David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
To: Chris J Arges <chris.j.arges-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
Return-path: <dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
In-Reply-To: <1437500193-10255-1-git-send-email-chris.j.arges-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
List-Unsubscribe: <http://openvswitch.org/mailman/options/dev>,
 <mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=unsubscribe>
List-Archive: <http://openvswitch.org/pipermail/dev>
List-Post: <mailto:dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
List-Help: <mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=help>
List-Subscribe: <http://openvswitch.org/mailman/listinfo/dev>,
 <mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=subscribe>
Errors-To: dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org
Sender: "dev" <dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
List-Id: netdev.vger.kernel.org

T24gVHVlLCBKdWwgMjEsIDIwMTUgYXQgMTA6MzYgQU0sIENocmlzIEogQXJnZXMKPGNocmlzLmou
YXJnZXNAY2Fub25pY2FsLmNvbT4gd3JvdGU6Cj4gU29tZSBhcmNoaXRlY3R1cmVzIGxpa2UgUE9X
RVIgY2FuIGhhdmUgYSBOVU1BIG5vZGVfcG9zc2libGVfbWFwIHRoYXQKPiBjb250YWlucyBzcGFy
c2UgZW50cmllcy4gVGhpcyBjYXVzZXMgbWVtb3J5IGNvcnJ1cHRpb24gd2l0aCBvcGVudnN3aXRj
aAo+IHNpbmNlIGl0IGFsbG9jYXRlcyBmbG93X2NhY2hlIHdpdGggYSBtdWx0aXBsZSBvZiBudW1f
cG9zc2libGVfbm9kZXMoKSBhbmQKPiBhc3N1bWVzIHRoZSBub2RlIHZhcmlhYmxlIHJldHVybmVk
IGJ5IGZvcl9lYWNoX25vZGUgd2lsbCBpbmRleCBpbnRvCj4gZmxvdy0+c3RhdHNbbm9kZV0uCj4K
PiBVc2UgbnJfbm9kZV9pZHMgdG8gYWxsb2NhdGUgYSBtYXhpbWFsIHNwYXJzZSBhcnJheSBpbnN0
ZWFkIG9mCj4gbnVtX3Bvc3NpYmxlX25vZGVzKCkuCj4KPiBUaGUgY3Jhc2ggd2FzIG5vdGljZWQg
YWZ0ZXIgM2FmMjI5ZjIgd2FzIGFwcGxpZWQgYXMgaXQgY2hhbmdlZCB0aGUKPiBub2RlX3Bvc3Np
YmxlX21hcCB0byBtYXRjaCBub2RlX29ubGluZV9tYXAgb24gYm9vdC4KPiBGaXhlczogM2FmMjI5
ZjIwNzFmNWI1Y2IzMTY2NGJlNjEwOTU2MWZiZTE5Yzg2MQo+Cj4gU2lnbmVkLW9mZi1ieTogQ2hy
aXMgSiBBcmdlcyA8Y2hyaXMuai5hcmdlc0BjYW5vbmljYWwuY29tPgoKQWNrZWQtYnk6IFByYXZp
biBCIFNoZWxhciA8cHNoZWxhckBuaWNpcmEuY29tPgoKVGhhbmtzLgpfX19fX19fX19fX19fX19f
X19fX19fX19fX19fX19fX19fX19fX19fX19fX19fXwpkZXYgbWFpbGluZyBsaXN0CmRldkBvcGVu
dnN3aXRjaC5vcmcKaHR0cDovL29wZW52c3dpdGNoLm9yZy9tYWlsbWFuL2xpc3RpbmZvL2Rldgo=
