From: Jesper Dangaard Brouer via iovisor-dev <iovisor-dev-9jONkmmOlFHEE9lA1F8Ukti2O/JbrIOy@public.gmane.org>
Subject: XDP (eXpress Data Path) documentation
Date: Tue, 20 Sep 2016 11:08:44 +0200
Message-ID: <20160920110844.661965be@redhat.com>
Reply-To: Jesper Dangaard Brouer <brouer-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Jonathan Corbet <corbet-T1hC0tSOHrs@public.gmane.org>, Nathan Willis <nate-T1hC0tSOHrs@public.gmane.org>,
	Alexei Starovoitov <ast-b10kYP2dOMg@public.gmane.org>,
	Tom Herbert <tom-BjP2VixgY4xUbtYUoyoikg@public.gmane.org>, linux-doc-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Saeed Mahameed <saeedm-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
To: "netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"iovisor-dev-9jONkmmOlFHEE9lA1F8Ukti2O/JbrIOy@public.gmane.org" <iovisor-dev-9jONkmmOlFHEE9lA1F8Ukti2O/JbrIOy@public.gmane.org>
Return-path: <iovisor-dev-bounces-9jONkmmOlFHEE9lA1F8Ukti2O/JbrIOy@public.gmane.org>
List-Unsubscribe: <https://lists.iovisor.org/mailman/options/iovisor-dev>,
	<mailto:iovisor-dev-request-9jONkmmOlFHEE9lA1F8Ukti2O/JbrIOy@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.iovisor.org/pipermail/iovisor-dev/>
List-Post: <mailto:iovisor-dev-9jONkmmOlFHEE9lA1F8Ukti2O/JbrIOy@public.gmane.org>
List-Help: <mailto:iovisor-dev-request-9jONkmmOlFHEE9lA1F8Ukti2O/JbrIOy@public.gmane.org?subject=help>
List-Subscribe: <https://lists.iovisor.org/mailman/listinfo/iovisor-dev>,
	<mailto:iovisor-dev-request-9jONkmmOlFHEE9lA1F8Ukti2O/JbrIOy@public.gmane.org?subject=subscribe>
Sender: iovisor-dev-bounces-9jONkmmOlFHEE9lA1F8Ukti2O/JbrIOy@public.gmane.org
Errors-To: iovisor-dev-bounces-9jONkmmOlFHEE9lA1F8Ukti2O/JbrIOy@public.gmane.org
List-Id: netdev.vger.kernel.org

Hi all,

As promised, I've started documenting the XDP eXpress Data Path):

 [1] https://prototype-kernel.readthedocs.io/en/latest/networking/XDP/index.html

IMHO the documentation have reached a stage where it is useful for the
XDP project, BUT I request collaboration on improving the documentation
from all. (Native English speakers are encouraged to send grammar fixes ;-))

You wouldn't believe it: But this pretty looking documentation actually
follows the new Kernel documentation format.  It is actually just
".rst" text files stored in my github repository under kernel/Documentation [2]

 [2] https://github.com/netoptimizer/prototype-kernel/tree/master/kernel/Documentation

Thus, just git clone my repository and started editing and send me
patches (or github pull requests). Like:

 $ git clone https://github.com/netoptimizer/prototype-kernel
 $ cd prototype-kernel/kernel/Documentation/
 $ make html
 $ firefox _build/html/index.html &

This new documentation format combines the best of two worlds, pretty
online browser documentation with almost plain text files, and changes
being tracked via git commits [3] (and auto git hooks to generate the
readthedocs.org page). You got to love it! :-)

-- 
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Principal Kernel Engineer at Red Hat
  Author of http://www.iptv-analyzer.org
  LinkedIn: http://www.linkedin.com/in/brouer

[3] https://github.com/netoptimizer/prototype-kernel/commits/master
