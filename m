From: Wang Jian <lark@linux.net.cn>
Subject: Re: [PATCH] improvement on net/sched/cls_fw.c's hash function
Date: Tue, 05 Apr 2005 14:05:56 +0800
Message-ID: <20050405140342.024A.LARK@linux.net.cn>
References: <20050405133336.0247.LARK@linux.net.cn> <20050404223744.1f04c130.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="------_42522A3E043B033D6C20_MULTIPART_MIXED_"
Content-Transfer-Encoding: 7bit
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
In-Reply-To: <20050404223744.1f04c130.davem@davemloft.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

--------_42522A3E043B033D6C20_MULTIPART_MIXED_
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit

Hi David S. Miller,

New patch attached. Hashsize is 256, the same as old one.


On Mon, 4 Apr 2005 22:37:44 -0700, "David S. Miller" <davem@davemloft.net> wrote:

> On Tue, 05 Apr 2005 13:35:02 +0800
> Wang Jian <lark@linux.net.cn> wrote:
> 
> > https://lists.netfilter.org/pipermail/netfilter-devel/2005-March/018762.html
> > 
> > I chose 509 for FW_FILTER_HSIZE. If you feel it is waste of memory, then
> > 251 is good too.
> 
> Please us a power of two, the "%" is expensive on some cpus.



-- 
  lark

--------_42522A3E043B033D6C20_MULTIPART_MIXED_
Content-Type: application/octet-stream;
 name="hash-cls_fw-2.diff"
Content-Disposition: attachment;
 filename="hash-cls_fw-2.diff"
Content-Transfer-Encoding: base64

SW5kZXg6IGxpbnV4LTIuNi4xMS13L25ldC9zY2hlZC9jbHNfZncuYwo9PT09PT09PT09PT09PT09
PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09Ci0tLSBs
aW51eC0yLjYuMTEtdy9uZXQvc2NoZWQvY2xzX2Z3LmMJKHJldmlzaW9uIDEpCisrKyBsaW51eC0y
LjYuMTEtdy9uZXQvc2NoZWQvY2xzX2Z3LmMJKHdvcmtpbmcgY29weSkKQEAgLTQ1LDEwICs0NSwx
MyBAQAogI2luY2x1ZGUgPG5ldC9zb2NrLmg+CiAjaW5jbHVkZSA8bmV0L2FjdF9hcGkuaD4KICNp
bmNsdWRlIDxuZXQvcGt0X2Nscy5oPgorI2luY2x1ZGUgPGxpbnV4L2poYXNoLmg+CiAKKyNkZWZp
bmUgRldfRklMVEVSX0hTSVpFCQkyNTYKKwogc3RydWN0IGZ3X2hlYWQKIHsKLQlzdHJ1Y3QgZndf
ZmlsdGVyICpodFsyNTZdOworCXN0cnVjdCBmd19maWx0ZXIgKmh0W0ZXX0ZJTFRFUl9IU0laRV07
CiB9OwogCiBzdHJ1Y3QgZndfZmlsdGVyCkBAIC02OSw3ICs3Miw3IEBACiAKIHN0YXRpYyBfX2lu
bGluZV9fIGludCBmd19oYXNoKHUzMiBoYW5kbGUpCiB7Ci0JcmV0dXJuIGhhbmRsZSYweEZGOwor
CXJldHVybiAoamhhc2hfMXdvcmQoaGFuZGxlLCAweEYzMEE3MTI5KSAlIEZXX0ZJTFRFUl9IU0la
RSk7CiB9CiAKIHN0YXRpYyBpbnQgZndfY2xhc3NpZnkoc3RydWN0IHNrX2J1ZmYgKnNrYiwgc3Ry
dWN0IHRjZl9wcm90byAqdHAsCkBAIC0xNTIsNyArMTU1LDcgQEAKIAlpZiAoaGVhZCA9PSBOVUxM
KQogCQlyZXR1cm47CiAKLQlmb3IgKGg9MDsgaDwyNTY7IGgrKykgeworCWZvciAoaD0wOyBoPEZX
X0ZJTFRFUl9IU0laRTsgaCsrKSB7CiAJCXdoaWxlICgoZj1oZWFkLT5odFtoXSkgIT0gTlVMTCkg
ewogCQkJaGVhZC0+aHRbaF0gPSBmLT5uZXh0OwogCQkJZndfZGVsZXRlX2ZpbHRlcih0cCwgZik7
CkBAIC0yOTEsNyArMjk0LDcgQEAKIAlpZiAoYXJnLT5zdG9wKQogCQlyZXR1cm47CiAKLQlmb3Ig
KGggPSAwOyBoIDwgMjU2OyBoKyspIHsKKwlmb3IgKGggPSAwOyBoIDwgRldfRklMVEVSX0hTSVpF
OyBoKyspIHsKIAkJc3RydWN0IGZ3X2ZpbHRlciAqZjsKIAogCQlmb3IgKGYgPSBoZWFkLT5odFto
XTsgZjsgZiA9IGYtPm5leHQpIHsK
--------_42522A3E043B033D6C20_MULTIPART_MIXED_--
