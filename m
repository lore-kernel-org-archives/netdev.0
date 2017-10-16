From: kbuild test robot <fengguang.wu@intel.com>
Subject: [net-next:master 277/285] include/trace/events/xdp.h:91:17: warning:
 'struct bpf_map' declared inside parameter list will not be visible outside
 of this definition or declaration
Date: Tue, 17 Oct 2017 07:27:50 +0800
Message-ID: <201710170747.E2urD1eO%fengguang.wu@intel.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="NzB8fVQJ5HfG6fxh"
Cc: kbuild-all@01.org, netdev@vger.kernel.org
To: "Steven Rostedt (VMware)" <rostedt@goodmis.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([134.134.136.65]:35142 "EHLO mga03.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1756997AbdJPX2v (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 16 Oct 2017 19:28:51 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--NzB8fVQJ5HfG6fxh
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

tree:   https://git.kernel.org/pub/scm/linux/kernel/git/davem/net-next.git master
head:   e4467f2e2442e15cf047c2e7b91cb44a643cb149
commit: 9185a610f8f7f1b4e4d28c9de27d1969cf58e0f1 [277/285] tracing: bpf: Hide bpf trace events when they are not used
config: i386-randconfig-x0-10170550 (attached as .config)
compiler: gcc-6 (Debian 6.2.0-3) 6.2.0 20160901
reproduce:
        git checkout 9185a610f8f7f1b4e4d28c9de27d1969cf58e0f1
        # save the attached .config to linux build tree
        make ARCH=i386 

All warnings (new ones prefixed by >>):

   In file included from include/trace/events/xdp.h:9:0,
                    from include/linux/bpf_trace.h:5,
                    from drivers/net/ethernet/mellanox/mlx5/core/en_rx.c:37:
>> include/trace/events/xdp.h:91:17: warning: 'struct bpf_map' declared inside parameter list will not be visible outside of this definition or declaration
       const struct bpf_map *map, u32 map_index),
                    ^
   include/linux/tracepoint.h:187:34: note: in definition of macro '__DECLARE_TRACE'
     static inline void trace_##name(proto)    \
                                     ^~~~~
>> include/linux/tracepoint.h:352:24: note: in expansion of macro 'PARAMS'
     __DECLARE_TRACE(name, PARAMS(proto), PARAMS(args),  \
                           ^~~~~~
   include/linux/tracepoint.h:477:2: note: in expansion of macro 'DECLARE_TRACE'
     DECLARE_TRACE(name, PARAMS(proto), PARAMS(args))
     ^~~~~~~~~~~~~
   include/linux/tracepoint.h:477:22: note: in expansion of macro 'PARAMS'
     DECLARE_TRACE(name, PARAMS(proto), PARAMS(args))
                         ^~~~~~
>> include/trace/events/xdp.h:87:1: note: in expansion of macro 'DEFINE_EVENT'
    DEFINE_EVENT(xdp_redirect_template, xdp_redirect,
    ^~~~~~~~~~~~
>> include/trace/events/xdp.h:88:2: note: in expansion of macro 'TP_PROTO'
     TP_PROTO(const struct net_device *dev,
     ^~~~~~~~
>> include/trace/events/xdp.h:91:17: warning: 'struct bpf_map' declared inside parameter list will not be visible outside of this definition or declaration
       const struct bpf_map *map, u32 map_index),
                    ^
   include/linux/tracepoint.h:203:38: note: in definition of macro '__DECLARE_TRACE'
     register_trace_##name(void (*probe)(data_proto), void *data) \
                                         ^~~~~~~~~~
   include/linux/tracepoint.h:354:4: note: in expansion of macro 'PARAMS'
       PARAMS(void *__data, proto),   \
       ^~~~~~
   include/linux/tracepoint.h:477:2: note: in expansion of macro 'DECLARE_TRACE'
     DECLARE_TRACE(name, PARAMS(proto), PARAMS(args))
     ^~~~~~~~~~~~~
   include/linux/tracepoint.h:477:22: note: in expansion of macro 'PARAMS'
     DECLARE_TRACE(name, PARAMS(proto), PARAMS(args))
                         ^~~~~~
>> include/trace/events/xdp.h:87:1: note: in expansion of macro 'DEFINE_EVENT'
    DEFINE_EVENT(xdp_redirect_template, xdp_redirect,
    ^~~~~~~~~~~~
>> include/trace/events/xdp.h:88:2: note: in expansion of macro 'TP_PROTO'
     TP_PROTO(const struct net_device *dev,
     ^~~~~~~~
>> include/trace/events/xdp.h:91:17: warning: 'struct bpf_map' declared inside parameter list will not be visible outside of this definition or declaration
       const struct bpf_map *map, u32 map_index),
                    ^
   include/linux/tracepoint.h:209:43: note: in definition of macro '__DECLARE_TRACE'
     register_trace_prio_##name(void (*probe)(data_proto), void *data,\
                                              ^~~~~~~~~~
   include/linux/tracepoint.h:354:4: note: in expansion of macro 'PARAMS'
       PARAMS(void *__data, proto),   \
       ^~~~~~
   include/linux/tracepoint.h:477:2: note: in expansion of macro 'DECLARE_TRACE'
     DECLARE_TRACE(name, PARAMS(proto), PARAMS(args))
     ^~~~~~~~~~~~~
   include/linux/tracepoint.h:477:22: note: in expansion of macro 'PARAMS'
     DECLARE_TRACE(name, PARAMS(proto), PARAMS(args))
                         ^~~~~~
>> include/trace/events/xdp.h:87:1: note: in expansion of macro 'DEFINE_EVENT'
    DEFINE_EVENT(xdp_redirect_template, xdp_redirect,
    ^~~~~~~~~~~~
>> include/trace/events/xdp.h:88:2: note: in expansion of macro 'TP_PROTO'
     TP_PROTO(const struct net_device *dev,
     ^~~~~~~~
>> include/trace/events/xdp.h:91:17: warning: 'struct bpf_map' declared inside parameter list will not be visible outside of this definition or declaration
       const struct bpf_map *map, u32 map_index),
                    ^
   include/linux/tracepoint.h:216:40: note: in definition of macro '__DECLARE_TRACE'
     unregister_trace_##name(void (*probe)(data_proto), void *data) \
                                           ^~~~~~~~~~
   include/linux/tracepoint.h:354:4: note: in expansion of macro 'PARAMS'
       PARAMS(void *__data, proto),   \
       ^~~~~~
   include/linux/tracepoint.h:477:2: note: in expansion of macro 'DECLARE_TRACE'
     DECLARE_TRACE(name, PARAMS(proto), PARAMS(args))
     ^~~~~~~~~~~~~
   include/linux/tracepoint.h:477:22: note: in expansion of macro 'PARAMS'
     DECLARE_TRACE(name, PARAMS(proto), PARAMS(args))
                         ^~~~~~
>> include/trace/events/xdp.h:87:1: note: in expansion of macro 'DEFINE_EVENT'
    DEFINE_EVENT(xdp_redirect_template, xdp_redirect,
    ^~~~~~~~~~~~
>> include/trace/events/xdp.h:88:2: note: in expansion of macro 'TP_PROTO'
     TP_PROTO(const struct net_device *dev,
     ^~~~~~~~
>> include/trace/events/xdp.h:91:17: warning: 'struct bpf_map' declared inside parameter list will not be visible outside of this definition or declaration
       const struct bpf_map *map, u32 map_index),
                    ^
   include/linux/tracepoint.h:222:46: note: in definition of macro '__DECLARE_TRACE'
     check_trace_callback_type_##name(void (*cb)(data_proto)) \
                                                 ^~~~~~~~~~
   include/linux/tracepoint.h:354:4: note: in expansion of macro 'PARAMS'
       PARAMS(void *__data, proto),   \
       ^~~~~~
   include/linux/tracepoint.h:477:2: note: in expansion of macro 'DECLARE_TRACE'
     DECLARE_TRACE(name, PARAMS(proto), PARAMS(args))
     ^~~~~~~~~~~~~
   include/linux/tracepoint.h:477:22: note: in expansion of macro 'PARAMS'
     DECLARE_TRACE(name, PARAMS(proto), PARAMS(args))
                         ^~~~~~
>> include/trace/events/xdp.h:87:1: note: in expansion of macro 'DEFINE_EVENT'
    DEFINE_EVENT(xdp_redirect_template, xdp_redirect,
    ^~~~~~~~~~~~
>> include/trace/events/xdp.h:88:2: note: in expansion of macro 'TP_PROTO'
     TP_PROTO(const struct net_device *dev,
     ^~~~~~~~
   include/trace/events/xdp.h:99:17: warning: 'struct bpf_map' declared inside parameter list will not be visible outside of this definition or declaration
       const struct bpf_map *map, u32 map_index),
                    ^
   include/linux/tracepoint.h:187:34: note: in definition of macro '__DECLARE_TRACE'
     static inline void trace_##name(proto)    \
                                     ^~~~~
>> include/linux/tracepoint.h:352:24: note: in expansion of macro 'PARAMS'
     __DECLARE_TRACE(name, PARAMS(proto), PARAMS(args),  \
                           ^~~~~~
   include/linux/tracepoint.h:477:2: note: in expansion of macro 'DECLARE_TRACE'
     DECLARE_TRACE(name, PARAMS(proto), PARAMS(args))
     ^~~~~~~~~~~~~
   include/linux/tracepoint.h:477:22: note: in expansion of macro 'PARAMS'
     DECLARE_TRACE(name, PARAMS(proto), PARAMS(args))
                         ^~~~~~
   include/trace/events/xdp.h:95:1: note: in expansion of macro 'DEFINE_EVENT'
    DEFINE_EVENT(xdp_redirect_template, xdp_redirect_err,
    ^~~~~~~~~~~~
   include/trace/events/xdp.h:96:2: note: in expansion of macro 'TP_PROTO'
     TP_PROTO(const struct net_device *dev,
     ^~~~~~~~
   include/trace/events/xdp.h:99:17: warning: 'struct bpf_map' declared inside parameter list will not be visible outside of this definition or declaration
       const struct bpf_map *map, u32 map_index),
                    ^
   include/linux/tracepoint.h:203:38: note: in definition of macro '__DECLARE_TRACE'
     register_trace_##name(void (*probe)(data_proto), void *data) \
                                         ^~~~~~~~~~
   include/linux/tracepoint.h:354:4: note: in expansion of macro 'PARAMS'
       PARAMS(void *__data, proto),   \
       ^~~~~~
   include/linux/tracepoint.h:477:2: note: in expansion of macro 'DECLARE_TRACE'
     DECLARE_TRACE(name, PARAMS(proto), PARAMS(args))
     ^~~~~~~~~~~~~
   include/linux/tracepoint.h:477:22: note: in expansion of macro 'PARAMS'
     DECLARE_TRACE(name, PARAMS(proto), PARAMS(args))
                         ^~~~~~
   include/trace/events/xdp.h:95:1: note: in expansion of macro 'DEFINE_EVENT'
    DEFINE_EVENT(xdp_redirect_template, xdp_redirect_err,
    ^~~~~~~~~~~~
   include/trace/events/xdp.h:96:2: note: in expansion of macro 'TP_PROTO'
     TP_PROTO(const struct net_device *dev,
     ^~~~~~~~
   include/trace/events/xdp.h:99:17: warning: 'struct bpf_map' declared inside parameter list will not be visible outside of this definition or declaration
       const struct bpf_map *map, u32 map_index),
                    ^
   include/linux/tracepoint.h:209:43: note: in definition of macro '__DECLARE_TRACE'
     register_trace_prio_##name(void (*probe)(data_proto), void *data,\
                                              ^~~~~~~~~~
   include/linux/tracepoint.h:354:4: note: in expansion of macro 'PARAMS'
       PARAMS(void *__data, proto),   \
       ^~~~~~
   include/linux/tracepoint.h:477:2: note: in expansion of macro 'DECLARE_TRACE'
     DECLARE_TRACE(name, PARAMS(proto), PARAMS(args))
     ^~~~~~~~~~~~~
   include/linux/tracepoint.h:477:22: note: in expansion of macro 'PARAMS'
     DECLARE_TRACE(name, PARAMS(proto), PARAMS(args))
                         ^~~~~~
   include/trace/events/xdp.h:95:1: note: in expansion of macro 'DEFINE_EVENT'
    DEFINE_EVENT(xdp_redirect_template, xdp_redirect_err,
    ^~~~~~~~~~~~
   include/trace/events/xdp.h:96:2: note: in expansion of macro 'TP_PROTO'
     TP_PROTO(const struct net_device *dev,
     ^~~~~~~~
   include/trace/events/xdp.h:99:17: warning: 'struct bpf_map' declared inside parameter list will not be visible outside of this definition or declaration
       const struct bpf_map *map, u32 map_index),
                    ^
   include/linux/tracepoint.h:216:40: note: in definition of macro '__DECLARE_TRACE'
     unregister_trace_##name(void (*probe)(data_proto), void *data) \
                                           ^~~~~~~~~~
   include/linux/tracepoint.h:354:4: note: in expansion of macro 'PARAMS'
       PARAMS(void *__data, proto),   \
       ^~~~~~
   include/linux/tracepoint.h:477:2: note: in expansion of macro 'DECLARE_TRACE'
     DECLARE_TRACE(name, PARAMS(proto), PARAMS(args))
     ^~~~~~~~~~~~~
   include/linux/tracepoint.h:477:22: note: in expansion of macro 'PARAMS'
     DECLARE_TRACE(name, PARAMS(proto), PARAMS(args))
                         ^~~~~~
   include/trace/events/xdp.h:95:1: note: in expansion of macro 'DEFINE_EVENT'
    DEFINE_EVENT(xdp_redirect_template, xdp_redirect_err,
    ^~~~~~~~~~~~
   include/trace/events/xdp.h:96:2: note: in expansion of macro 'TP_PROTO'
     TP_PROTO(const struct net_device *dev,
     ^~~~~~~~
   include/trace/events/xdp.h:99:17: warning: 'struct bpf_map' declared inside parameter list will not be visible outside of this definition or declaration
       const struct bpf_map *map, u32 map_index),
                    ^
   include/linux/tracepoint.h:222:46: note: in definition of macro '__DECLARE_TRACE'
     check_trace_callback_type_##name(void (*cb)(data_proto)) \
                                                 ^~~~~~~~~~
   include/linux/tracepoint.h:354:4: note: in expansion of macro 'PARAMS'
       PARAMS(void *__data, proto),   \
       ^~~~~~
   include/linux/tracepoint.h:477:2: note: in expansion of macro 'DECLARE_TRACE'
     DECLARE_TRACE(name, PARAMS(proto), PARAMS(args))
     ^~~~~~~~~~~~~
   include/linux/tracepoint.h:477:22: note: in expansion of macro 'PARAMS'
     DECLARE_TRACE(name, PARAMS(proto), PARAMS(args))
                         ^~~~~~
   include/trace/events/xdp.h:95:1: note: in expansion of macro 'DEFINE_EVENT'
    DEFINE_EVENT(xdp_redirect_template, xdp_redirect_err,
    ^~~~~~~~~~~~
   include/trace/events/xdp.h:96:2: note: in expansion of macro 'TP_PROTO'
     TP_PROTO(const struct net_device *dev,
     ^~~~~~~~
   include/trace/events/xdp.h:113:17: warning: 'struct bpf_map' declared inside parameter list will not be visible outside of this definition or declaration
       const struct bpf_map *map, u32 map_index),
                    ^
   include/linux/tracepoint.h:187:34: note: in definition of macro '__DECLARE_TRACE'
     static inline void trace_##name(proto)    \
                                     ^~~~~
>> include/linux/tracepoint.h:352:24: note: in expansion of macro 'PARAMS'
     __DECLARE_TRACE(name, PARAMS(proto), PARAMS(args),  \
                           ^~~~~~
   include/linux/tracepoint.h:481:2: note: in expansion of macro 'DECLARE_TRACE'
     DECLARE_TRACE(name, PARAMS(proto), PARAMS(args))
     ^~~~~~~~~~~~~
   include/linux/tracepoint.h:481:22: note: in expansion of macro 'PARAMS'
     DECLARE_TRACE(name, PARAMS(proto), PARAMS(args))
                         ^~~~~~
>> include/trace/events/xdp.h:109:1: note: in expansion of macro 'DEFINE_EVENT_PRINT'
    DEFINE_EVENT_PRINT(xdp_redirect_template, xdp_redirect_map,
    ^~~~~~~~~~~~~~~~~~
   include/trace/events/xdp.h:110:2: note: in expansion of macro 'TP_PROTO'
     TP_PROTO(const struct net_device *dev,
     ^~~~~~~~
   include/trace/events/xdp.h:113:17: warning: 'struct bpf_map' declared inside parameter list will not be visible outside of this definition or declaration
       const struct bpf_map *map, u32 map_index),
                    ^
   include/linux/tracepoint.h:203:38: note: in definition of macro '__DECLARE_TRACE'
     register_trace_##name(void (*probe)(data_proto), void *data) \
                                         ^~~~~~~~~~
   include/linux/tracepoint.h:354:4: note: in expansion of macro 'PARAMS'
       PARAMS(void *__data, proto),   \
       ^~~~~~
   include/linux/tracepoint.h:481:2: note: in expansion of macro 'DECLARE_TRACE'
     DECLARE_TRACE(name, PARAMS(proto), PARAMS(args))
     ^~~~~~~~~~~~~
   include/linux/tracepoint.h:481:22: note: in expansion of macro 'PARAMS'
     DECLARE_TRACE(name, PARAMS(proto), PARAMS(args))
                         ^~~~~~
>> include/trace/events/xdp.h:109:1: note: in expansion of macro 'DEFINE_EVENT_PRINT'
    DEFINE_EVENT_PRINT(xdp_redirect_template, xdp_redirect_map,
    ^~~~~~~~~~~~~~~~~~
   include/trace/events/xdp.h:110:2: note: in expansion of macro 'TP_PROTO'
     TP_PROTO(const struct net_device *dev,
     ^~~~~~~~
   include/trace/events/xdp.h:113:17: warning: 'struct bpf_map' declared inside parameter list will not be visible outside of this definition or declaration
       const struct bpf_map *map, u32 map_index),
                    ^
   include/linux/tracepoint.h:209:43: note: in definition of macro '__DECLARE_TRACE'
     register_trace_prio_##name(void (*probe)(data_proto), void *data,\
                                              ^~~~~~~~~~
   include/linux/tracepoint.h:354:4: note: in expansion of macro 'PARAMS'
       PARAMS(void *__data, proto),   \
       ^~~~~~
   include/linux/tracepoint.h:481:2: note: in expansion of macro 'DECLARE_TRACE'
     DECLARE_TRACE(name, PARAMS(proto), PARAMS(args))
     ^~~~~~~~~~~~~
   include/linux/tracepoint.h:481:22: note: in expansion of macro 'PARAMS'
     DECLARE_TRACE(name, PARAMS(proto), PARAMS(args))
                         ^~~~~~

vim +91 include/trace/events/xdp.h

a67edbf4f Daniel Borkmann        2017-01-25    6  
a67edbf4f Daniel Borkmann        2017-01-25    7  #include <linux/netdevice.h>
a67edbf4f Daniel Borkmann        2017-01-25    8  #include <linux/filter.h>
a67edbf4f Daniel Borkmann        2017-01-25   @9  #include <linux/tracepoint.h>
a67edbf4f Daniel Borkmann        2017-01-25   10  
a67edbf4f Daniel Borkmann        2017-01-25   11  #define __XDP_ACT_MAP(FN)	\
a67edbf4f Daniel Borkmann        2017-01-25   12  	FN(ABORTED)		\
a67edbf4f Daniel Borkmann        2017-01-25   13  	FN(DROP)		\
a67edbf4f Daniel Borkmann        2017-01-25   14  	FN(PASS)		\
5acaee0a8 John Fastabend         2017-07-17   15  	FN(TX)			\
5acaee0a8 John Fastabend         2017-07-17   16  	FN(REDIRECT)
a67edbf4f Daniel Borkmann        2017-01-25   17  
a67edbf4f Daniel Borkmann        2017-01-25   18  #define __XDP_ACT_TP_FN(x)	\
a67edbf4f Daniel Borkmann        2017-01-25   19  	TRACE_DEFINE_ENUM(XDP_##x);
a67edbf4f Daniel Borkmann        2017-01-25   20  #define __XDP_ACT_SYM_FN(x)	\
a67edbf4f Daniel Borkmann        2017-01-25   21  	{ XDP_##x, #x },
a67edbf4f Daniel Borkmann        2017-01-25   22  #define __XDP_ACT_SYM_TAB	\
a67edbf4f Daniel Borkmann        2017-01-25   23  	__XDP_ACT_MAP(__XDP_ACT_SYM_FN) { -1, 0 }
a67edbf4f Daniel Borkmann        2017-01-25   24  __XDP_ACT_MAP(__XDP_ACT_TP_FN)
a67edbf4f Daniel Borkmann        2017-01-25   25  
a67edbf4f Daniel Borkmann        2017-01-25   26  TRACE_EVENT(xdp_exception,
a67edbf4f Daniel Borkmann        2017-01-25   27  
a67edbf4f Daniel Borkmann        2017-01-25   28  	TP_PROTO(const struct net_device *dev,
a67edbf4f Daniel Borkmann        2017-01-25   29  		 const struct bpf_prog *xdp, u32 act),
a67edbf4f Daniel Borkmann        2017-01-25   30  
a67edbf4f Daniel Borkmann        2017-01-25   31  	TP_ARGS(dev, xdp, act),
a67edbf4f Daniel Borkmann        2017-01-25   32  
a67edbf4f Daniel Borkmann        2017-01-25   33  	TP_STRUCT__entry(
b06337dfd Jesper Dangaard Brouer 2017-08-29   34  		__field(int, prog_id)
a67edbf4f Daniel Borkmann        2017-01-25   35  		__field(u32, act)
315ec3990 Jesper Dangaard Brouer 2017-08-24   36  		__field(int, ifindex)
a67edbf4f Daniel Borkmann        2017-01-25   37  	),
a67edbf4f Daniel Borkmann        2017-01-25   38  
a67edbf4f Daniel Borkmann        2017-01-25   39  	TP_fast_assign(
b06337dfd Jesper Dangaard Brouer 2017-08-29   40  		__entry->prog_id	= xdp->aux->id;
a67edbf4f Daniel Borkmann        2017-01-25   41  		__entry->act		= act;
315ec3990 Jesper Dangaard Brouer 2017-08-24   42  		__entry->ifindex	= dev->ifindex;
a67edbf4f Daniel Borkmann        2017-01-25   43  	),
a67edbf4f Daniel Borkmann        2017-01-25   44  
b06337dfd Jesper Dangaard Brouer 2017-08-29   45  	TP_printk("prog_id=%d action=%s ifindex=%d",
b06337dfd Jesper Dangaard Brouer 2017-08-29   46  		  __entry->prog_id,
315ec3990 Jesper Dangaard Brouer 2017-08-24   47  		  __print_symbolic(__entry->act, __XDP_ACT_SYM_TAB),
315ec3990 Jesper Dangaard Brouer 2017-08-24   48  		  __entry->ifindex)
a67edbf4f Daniel Borkmann        2017-01-25   49  );
a67edbf4f Daniel Borkmann        2017-01-25   50  
8d3b778ff Jesper Dangaard Brouer 2017-08-29   51  DECLARE_EVENT_CLASS(xdp_redirect_template,
5acaee0a8 John Fastabend         2017-07-17   52  
a87358558 Jesper Dangaard Brouer 2017-08-24   53  	TP_PROTO(const struct net_device *dev,
c31e5a487 Jesper Dangaard Brouer 2017-08-29   54  		 const struct bpf_prog *xdp,
8d3b778ff Jesper Dangaard Brouer 2017-08-29   55  		 int to_ifindex, int err,
8d3b778ff Jesper Dangaard Brouer 2017-08-29   56  		 const struct bpf_map *map, u32 map_index),
5acaee0a8 John Fastabend         2017-07-17   57  
8d3b778ff Jesper Dangaard Brouer 2017-08-29   58  	TP_ARGS(dev, xdp, to_ifindex, err, map, map_index),
5acaee0a8 John Fastabend         2017-07-17   59  
5acaee0a8 John Fastabend         2017-07-17   60  	TP_STRUCT__entry(
b06337dfd Jesper Dangaard Brouer 2017-08-29   61  		__field(int, prog_id)
5acaee0a8 John Fastabend         2017-07-17   62  		__field(u32, act)
a87358558 Jesper Dangaard Brouer 2017-08-24   63  		__field(int, ifindex)
4c03bdd7b Jesper Dangaard Brouer 2017-08-17   64  		__field(int, err)
8d3b778ff Jesper Dangaard Brouer 2017-08-29   65  		__field(int, to_ifindex)
8d3b778ff Jesper Dangaard Brouer 2017-08-29   66  		__field(u32, map_id)
8d3b778ff Jesper Dangaard Brouer 2017-08-29   67  		__field(int, map_index)
5acaee0a8 John Fastabend         2017-07-17   68  	),
5acaee0a8 John Fastabend         2017-07-17   69  
5acaee0a8 John Fastabend         2017-07-17   70  	TP_fast_assign(
b06337dfd Jesper Dangaard Brouer 2017-08-29   71  		__entry->prog_id	= xdp->aux->id;
c31e5a487 Jesper Dangaard Brouer 2017-08-29   72  		__entry->act		= XDP_REDIRECT;
a87358558 Jesper Dangaard Brouer 2017-08-24   73  		__entry->ifindex	= dev->ifindex;
4c03bdd7b Jesper Dangaard Brouer 2017-08-17   74  		__entry->err		= err;
8d3b778ff Jesper Dangaard Brouer 2017-08-29   75  		__entry->to_ifindex	= to_ifindex;
8d3b778ff Jesper Dangaard Brouer 2017-08-29   76  		__entry->map_id		= map ? map->id : 0;
8d3b778ff Jesper Dangaard Brouer 2017-08-29   77  		__entry->map_index	= map_index;
5acaee0a8 John Fastabend         2017-07-17   78  	),
5acaee0a8 John Fastabend         2017-07-17   79  
59a308967 Jesper Dangaard Brouer 2017-08-29   80  	TP_printk("prog_id=%d action=%s ifindex=%d to_ifindex=%d err=%d",
b06337dfd Jesper Dangaard Brouer 2017-08-29   81  		  __entry->prog_id,
4c03bdd7b Jesper Dangaard Brouer 2017-08-17   82  		  __print_symbolic(__entry->act, __XDP_ACT_SYM_TAB),
8d3b778ff Jesper Dangaard Brouer 2017-08-29   83  		  __entry->ifindex, __entry->to_ifindex,
59a308967 Jesper Dangaard Brouer 2017-08-29   84  		  __entry->err)
5acaee0a8 John Fastabend         2017-07-17   85  );
8d3b778ff Jesper Dangaard Brouer 2017-08-29   86  
8d3b778ff Jesper Dangaard Brouer 2017-08-29  @87  DEFINE_EVENT(xdp_redirect_template, xdp_redirect,
8d3b778ff Jesper Dangaard Brouer 2017-08-29  @88  	TP_PROTO(const struct net_device *dev,
8d3b778ff Jesper Dangaard Brouer 2017-08-29   89  		 const struct bpf_prog *xdp,
8d3b778ff Jesper Dangaard Brouer 2017-08-29   90  		 int to_ifindex, int err,
8d3b778ff Jesper Dangaard Brouer 2017-08-29  @91  		 const struct bpf_map *map, u32 map_index),
8d3b778ff Jesper Dangaard Brouer 2017-08-29   92  	TP_ARGS(dev, xdp, to_ifindex, err, map, map_index)
8d3b778ff Jesper Dangaard Brouer 2017-08-29   93  );
8d3b778ff Jesper Dangaard Brouer 2017-08-29   94  
f5836ca5e Jesper Dangaard Brouer 2017-08-29   95  DEFINE_EVENT(xdp_redirect_template, xdp_redirect_err,
f5836ca5e Jesper Dangaard Brouer 2017-08-29   96  	TP_PROTO(const struct net_device *dev,
f5836ca5e Jesper Dangaard Brouer 2017-08-29   97  		 const struct bpf_prog *xdp,
f5836ca5e Jesper Dangaard Brouer 2017-08-29   98  		 int to_ifindex, int err,
f5836ca5e Jesper Dangaard Brouer 2017-08-29   99  		 const struct bpf_map *map, u32 map_index),
f5836ca5e Jesper Dangaard Brouer 2017-08-29  100  	TP_ARGS(dev, xdp, to_ifindex, err, map, map_index)
f5836ca5e Jesper Dangaard Brouer 2017-08-29  101  );
f5836ca5e Jesper Dangaard Brouer 2017-08-29  102  
f5836ca5e Jesper Dangaard Brouer 2017-08-29  103  #define _trace_xdp_redirect(dev, xdp, to)		\
f5836ca5e Jesper Dangaard Brouer 2017-08-29  104  	 trace_xdp_redirect(dev, xdp, to, 0, NULL, 0);
f5836ca5e Jesper Dangaard Brouer 2017-08-29  105  
f5836ca5e Jesper Dangaard Brouer 2017-08-29  106  #define _trace_xdp_redirect_err(dev, xdp, to, err)	\
f5836ca5e Jesper Dangaard Brouer 2017-08-29  107  	 trace_xdp_redirect_err(dev, xdp, to, err, NULL, 0);
f5836ca5e Jesper Dangaard Brouer 2017-08-29  108  
59a308967 Jesper Dangaard Brouer 2017-08-29 @109  DEFINE_EVENT_PRINT(xdp_redirect_template, xdp_redirect_map,
59a308967 Jesper Dangaard Brouer 2017-08-29  110  	TP_PROTO(const struct net_device *dev,
59a308967 Jesper Dangaard Brouer 2017-08-29  111  		 const struct bpf_prog *xdp,
59a308967 Jesper Dangaard Brouer 2017-08-29  112  		 int to_ifindex, int err,
59a308967 Jesper Dangaard Brouer 2017-08-29  113  		 const struct bpf_map *map, u32 map_index),
59a308967 Jesper Dangaard Brouer 2017-08-29  114  	TP_ARGS(dev, xdp, to_ifindex, err, map, map_index),
59a308967 Jesper Dangaard Brouer 2017-08-29  115  	TP_printk("prog_id=%d action=%s ifindex=%d to_ifindex=%d err=%d"
59a308967 Jesper Dangaard Brouer 2017-08-29  116  		  " map_id=%d map_index=%d",
59a308967 Jesper Dangaard Brouer 2017-08-29  117  		  __entry->prog_id,
59a308967 Jesper Dangaard Brouer 2017-08-29  118  		  __print_symbolic(__entry->act, __XDP_ACT_SYM_TAB),
59a308967 Jesper Dangaard Brouer 2017-08-29  119  		  __entry->ifindex, __entry->to_ifindex,
59a308967 Jesper Dangaard Brouer 2017-08-29  120  		  __entry->err,
59a308967 Jesper Dangaard Brouer 2017-08-29  121  		  __entry->map_id, __entry->map_index)
59a308967 Jesper Dangaard Brouer 2017-08-29  122  );
59a308967 Jesper Dangaard Brouer 2017-08-29  123  

:::::: The code at line 91 was first introduced by commit
:::::: 8d3b778ff544b369f0847e6c15f3e73057298aa4 xdp: tracepoint xdp_redirect also need a map argument

:::::: TO: Jesper Dangaard Brouer <brouer@redhat.com>
:::::: CC: David S. Miller <davem@davemloft.net>

---
0-DAY kernel test infrastructure                Open Source Technology Center
https://lists.01.org/pipermail/kbuild-all                   Intel Corporation

--NzB8fVQJ5HfG6fxh
Content-Type: application/gzip
Content-Disposition: attachment; filename=".config.gz"
Content-Transfer-Encoding: base64

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
AA==

--NzB8fVQJ5HfG6fxh--
