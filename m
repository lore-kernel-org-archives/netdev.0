From: Daniel Lezcano <daniel.lezcano@free.fr>
Subject: Re: [PATCH 1/7] ns: proc files for namespace naming policy.
Date: Sun, 08 May 2011 00:37:41 +0200
Message-ID: <4DC5C9B5.8050805@free.fr>
References: <m1tyd7p7tq.fsf@fess.ebiederm.org> <1304735101-1824-1-git-send-email-ebiederm@xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-arch@vger.kernel.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, linux-fsdevel@vger.kernel.org,
	jamal <hadi@cyberus.ca>,
	Linux Containers <containers@lists.osdl.org>,
	Renato Westphal <renatowestphal@gmail.com>
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <linux-arch-owner@vger.kernel.org>
In-Reply-To: <1304735101-1824-1-git-send-email-ebiederm@xmission.com>
Sender: linux-arch-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 05/07/2011 04:24 AM, Eric W. Biederman wrote:
> Create files under /proc/<pid>/ns/ to allow controlling the
> namespaces of a process.
>
> This addresses three specific problems that can make namespaces hard to
> work with.
> - Namespaces require a dedicated process to pin them in memory.
> - It is not possible to use a namespace unless you are the child
>    of the original creator.
> - Namespaces don't have names that userspace can use to talk about
>    them.
>
> The namespace files under /proc/<pid>/ns/ can be opened and the
> file descriptor can be used to talk about a specific namespace, and
> to keep the specified namespace alive.
>
> A namespace can be kept alive by either holding the file descriptor
> open or bind mounting the file someplace else.  aka:
> mount --bind /proc/self/ns/net /some/filesystem/path
> mount --bind /proc/self/fd/<N>  /some/filesystem/path
>
> This allows namespaces to be named with userspace policy.
>
> It requires additional support to make use of these filedescriptors
> and that will be comming in the following patches.
>
> Signed-off-by: Eric W. Biederman<ebiederm@xmission.com>
Acked-by: Daniel Lezcano <daniel.lezcano@free.fr>
