From: Wang Jian <lark@linux.net.cn>
Subject: [PATCH] improvement on net/sched/cls_fw.c's hash function
Date: Tue, 05 Apr 2005 13:35:02 +0800
Message-ID: <20050405133336.0247.LARK@linux.net.cn>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="------_42520103041705CB2AF8_MULTIPART_MIXED_"
Content-Transfer-Encoding: 7bit
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

--------_42520103041705CB2AF8_MULTIPART_MIXED_
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit

Hi,

This is a simple patch against net/sched/cls_fw.c. The idea of this
patch is discussed in this thread

https://lists.netfilter.org/pipermail/netfilter-devel/2005-March/018762.html

I chose 509 for FW_FILTER_HSIZE. If you feel it is waste of memory, then
251 is good too.

BTW: I don't know much about hash performance and hash distribution of
jhash. This is a quick fix.



-- 
  lark

--------_42520103041705CB2AF8_MULTIPART_MIXED_
Content-Type: application/octet-stream;
 name="hash-cls_fw.diff"
Content-Disposition: attachment;
 filename="hash-cls_fw.diff"
Content-Transfer-Encoding: base64

SW5kZXg6IGNsc19mdy5jCj09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09
PT09PT09PT09PT09PT09PT09PT09PT09PT0KLS0tIGNsc19mdy5jCShyZXZpc2lvbiAxKQorKysg
Y2xzX2Z3LmMJKHdvcmtpbmcgY29weSkKQEAgLTQ1LDEwICs0NSwxMyBAQAogI2luY2x1ZGUgPG5l
dC9zb2NrLmg+CiAjaW5jbHVkZSA8bmV0L2FjdF9hcGkuaD4KICNpbmNsdWRlIDxuZXQvcGt0X2Ns
cy5oPgorI2luY2x1ZGUgPGxpbnV4L2poYXNoLmg+CiAKKyNkZWZpbmUgRldfRklMVEVSX0hTSVpF
CQk1MDkKKwogc3RydWN0IGZ3X2hlYWQKIHsKLQlzdHJ1Y3QgZndfZmlsdGVyICpodFsyNTZdOwor
CXN0cnVjdCBmd19maWx0ZXIgKmh0W0ZXX0ZJTFRFUl9IU0laRV07CiB9OwogCiBzdHJ1Y3QgZndf
ZmlsdGVyCkBAIC02OSw3ICs3Miw3IEBACiAKIHN0YXRpYyBfX2lubGluZV9fIGludCBmd19oYXNo
KHUzMiBoYW5kbGUpCiB7Ci0JcmV0dXJuIGhhbmRsZSYweEZGOworCXJldHVybiAoamhhc2hfMXdv
cmQoaGFuZGxlLCAweEYzMEE3MTI5KSAlIEZXX0ZJTFRFUl9IU0laRSk7CiB9CiAKIHN0YXRpYyBp
bnQgZndfY2xhc3NpZnkoc3RydWN0IHNrX2J1ZmYgKnNrYiwgc3RydWN0IHRjZl9wcm90byAqdHAs
CkBAIC0xNTIsNyArMTU1LDcgQEAKIAlpZiAoaGVhZCA9PSBOVUxMKQogCQlyZXR1cm47CiAKLQlm
b3IgKGg9MDsgaDwyNTY7IGgrKykgeworCWZvciAoaD0wOyBoPEZXX0ZJTFRFUl9IU0laRTsgaCsr
KSB7CiAJCXdoaWxlICgoZj1oZWFkLT5odFtoXSkgIT0gTlVMTCkgewogCQkJaGVhZC0+aHRbaF0g
PSBmLT5uZXh0OwogCQkJZndfZGVsZXRlX2ZpbHRlcih0cCwgZik7CkBAIC0yOTEsNyArMjk0LDcg
QEAKIAlpZiAoYXJnLT5zdG9wKQogCQlyZXR1cm47CiAKLQlmb3IgKGggPSAwOyBoIDwgMjU2OyBo
KyspIHsKKwlmb3IgKGggPSAwOyBoIDwgRldfRklMVEVSX0hTSVpFOyBoKyspIHsKIAkJc3RydWN0
IGZ3X2ZpbHRlciAqZjsKIAogCQlmb3IgKGYgPSBoZWFkLT5odFtoXTsgZjsgZiA9IGYtPm5leHQp
IHsK
--------_42520103041705CB2AF8_MULTIPART_MIXED_--
