From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH 3/8] cgroup: implement cgroup_get_from_path() and expose
 cgroup_put()
Date: Tue, 22 Dec 2015 13:13:11 -0500
Message-ID: <20151222181311.GA5003@mtj.duckdns.org>
References: <1449527935-27056-1-git-send-email-tj@kernel.org>
 <1449527935-27056-4-git-send-email-tj@kernel.org>
 <20151222002240.GA6682@mail.hallyn.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, pablo@netfilter.org, kaber@trash.net,
	kadlec@blackhole.kfki.hu, daniel@iogearbox.net,
	daniel.wagner@bmw-carit.de, nhorman@tuxdriver.com,
	lizefan@huawei.com, hannes@cmpxchg.org, netdev@vger.kernel.org,
	netfilter-devel@vger.kernel.org, coreteam@netfilter.org,
	cgroups@vger.kernel.org, linux-kernel@vger.kernel.org,
	kernel-team@fb.com, ninasc@fb.com
To: "Serge E. Hallyn" <serge.hallyn@ubuntu.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20151222002240.GA6682@mail.hallyn.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello, Serge.

On Mon, Dec 21, 2015 at 06:22:41PM -0600, Serge E. Hallyn wrote:
> I'm trying to figure out how to handle this in the cgroup ns patchset.
> Is this going to be purely used internally?  From the user i see in
> this patchset it looks like I should leave it be (and have @path always
> be absolute)  Is that right?

Yeap, I don't think this function needs to worry about namespaces.

Thanks.

-- 
tejun
