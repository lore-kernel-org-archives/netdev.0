From: Thomas Graf <tgraf-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Re:
 =?gb2312?b?tPC4tDogIFtQQVRDSCBvcGVudnN3aXRjaCB2M10gbmV0?=
 =?gb2312?b?bGluazogSW1wbGVtZW50ICYgZW5hYmxlIG1lbW9yeSBtYXBwZWQgbmV0bGlu?=
 =?gb2312?b?ayBpL28=?=
Date: Wed, 04 Dec 2013 10:08:59 +0100
Message-ID: <529EF12B.5050205@redhat.com>
References: <1d9af26b2798901c68ae9aef704d6313b71d3287.1386069453.git.tgraf@redhat.com>
	<9C2DE4B8FE85984BA1B0581235F6B2ED0F5D440A@SZXEMA502-MBS.china.huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org" <dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>,
	"netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"fleitner-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org" <fleitner-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
To: Zhuangyuxin <zhuangyuxin-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>,
	"jesse-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org" <jesse-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org>, "blp-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org" <blp-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org>
Return-path: <dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
In-Reply-To: <9C2DE4B8FE85984BA1B0581235F6B2ED0F5D440A-tJwL4pWccCZdGU6diIvhbAK1hpo4iccwjNknBlVQO8k@public.gmane.org>
List-Unsubscribe: <http://openvswitch.org/mailman/options/dev>,
	<mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=unsubscribe>
List-Archive: <http://openvswitch.org/pipermail/dev>
List-Post: <mailto:dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
List-Help: <mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=help>
List-Subscribe: <http://openvswitch.org/mailman/listinfo/dev>,
	<mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=subscribe>
Sender: dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org
Errors-To: dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org
List-Id: netdev.vger.kernel.org

On 12/04/2013 02:54 AM, Zhuangyuxin wrote:
> In this patch, each frame takes 16k mem. For sockets used for upcall, does it make more sense to calculate frame size based on MTU of the netdev on the port?

I assume you mean max(MTU) over all ports? We would have to replace the
ring after each MTU change. Doing so in use is non trivial and
expensive. The
current frame size of 16K covers jumbo frames and is a sane default but can
certainly be optimized further on, f.e. as we possibly extend OVS user space
to handle GSO frames.
