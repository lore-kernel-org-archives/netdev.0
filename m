From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Subject: Re: [PATCH 06/21] userns: Print out socket uids in a user namespace
	aware fashion.
Date: Tue, 14 Aug 2012 21:47:09 -0700
Message-ID: <87has4hicy.fsf@xmission.com>
References: <87ehnav9n5.fsf@xmission.com>
	<1344889115-21610-1-git-send-email-ebiederm@xmission.com>
	<1344889115-21610-6-git-send-email-ebiederm@xmission.com>
	<201208132326.35045.remi@remlab.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: =?utf-8?Q?R=C3=A9mi_Denis-Courmont?= <remi-AzDNUFsAnHasTnJN9+BGXg@public.gmane.org>
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <201208132326.35045.remi-AzDNUFsAnHasTnJN9+BGXg@public.gmane.org> (=?utf-8?Q?=22R=C3=A9mi?=
	Denis-Courmont"'s message of "Mon, 13 Aug 2012 23:26:34 +0300")
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: netdev.vger.kernel.org

IlLDqW1pIERlbmlzLUNvdXJtb250IiA8cmVtaUByZW1sYWIubmV0PiB3cml0ZXM6Cgo+IExlIGx1
bmRpIDEzIGFvw7t0IDIwMTIgMjM6MTg6MjAsIHZvdXMgYXZleiDDqWNyaXQgOgo+PiBGcm9tOiAi
RXJpYyBXLiBCaWVkZXJtYW4iIDxlYmllZGVybUB4bWlzc2lvbi5jb20+Cj4+IAo+PiBDYzogRGF2
aWQgTWlsbGVyIDxkYXZlbUBkYXZlbWxvZnQubmV0Pgo+PiBDYzogQWxleGV5IEt1em5ldHNvdiA8
a3V6bmV0QG1zMi5pbnIuYWMucnU+Cj4+IENjOiBKYW1lcyBNb3JyaXMgPGptb3JyaXNAbmFtZWku
b3JnPgo+PiBDYzogSGlkZWFraSBZT1NISUZVSkkgPHlvc2hmdWppQGxpbnV4LWlwdjYub3JnPgo+
PiBDYzogUGF0cmljayBNY0hhcmR5IDxrYWJlckB0cmFzaC5uZXQ+Cj4+IENjOiBBcm5hbGRvIENh
cnZhbGhvIGRlIE1lbG8gPGFjbWVAZ2hvc3Rwcm90b2NvbHMubmV0Pgo+PiBDYzogVmxhZCBZYXNl
dmljaCA8dnlhc2V2aWNoQGdtYWlsLmNvbT4KPj4gQ2M6IFNyaWRoYXIgU2FtdWRyYWxhIDxzcmlA
dXMuaWJtLmNvbT4KPj4gQWNrZWQtYnk6IFNlcmdlIEhhbGx5biA8c2VyZ2UuaGFsbHluQGNhbm9u
aWNhbC5jb20+Cj4+IFNpZ25lZC1vZmYtYnk6IEVyaWMgVy4gQmllZGVybWFuIDxlYmllZGVybUB4
bWlzc2lvbi5jb20+Cj4KPiBGV0lXLCAuLi4KCldlbGwgSSB3aWxsIHRha2UgZXZlcnkgYml0IG9m
IHJldmlldyBJIGNhbiBnZXQuICBJdCBjYW4gYmUgdGVycmlibHkKZW1iYXJyYXNzaW5nIHRvIGRp
c2NvdmVyIHlvdSBtZXNzZWQgdXAgdWlkL2dpZCBoYW5kbGluZyBhbmQgbm8gb25lCm5vdGljZWQg
dGhlIHNlY3VyaXR5IGhvbGUgZm9yIDMga2VybmVsIHJlbGVhc2VzLi4uCgo+IEFja2VkLUJ5OiBS
w6ltaSBEZW5pcy1Db3VybW9udCA8cmVtaUByZW1sYWIubmV0PgpfX19fX19fX19fX19fX19fX19f
X19fX19fX19fX19fX19fX19fX19fX19fX19fXwpDb250YWluZXJzIG1haWxpbmcgbGlzdApDb250
YWluZXJzQGxpc3RzLmxpbnV4LWZvdW5kYXRpb24ub3JnCmh0dHBzOi8vbGlzdHMubGludXhmb3Vu
ZGF0aW9uLm9yZy9tYWlsbWFuL2xpc3RpbmZvL2NvbnRhaW5lcnM=
